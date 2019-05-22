import struct
import sys
from os.path import abspath, exists, isfile, basename, getsize

SECTOR_SIZE = 512
TRACK_LENGTH = 9
TRACK_SIZE = SECTOR_SIZE * TRACK_LENGTH
# CLUSTER_SIZE = 2
CLUSTER_SIZE = 38
CLUSTER_VOLUME = CLUSTER_SIZE * TRACK_SIZE
# CLUSTERS_COUNT = 19
CLUSTERS_COUNT = 1
# FILE_INFO_SIZE = TRACK_SIZE // CLUSTERS_COUNT
FILE_INFO_SIZE = 242


class IMG:
	_img_name = None
	MBR = None
	Clusters_table = None
	# Clusters = [bytearray(TRACK_SIZE) for _ in range(CLUSTERS_COUNT)]
	Clusters = [bytearray(CLUSTER_VOLUME) for _ in range(CLUSTERS_COUNT)]

	def __init__(self, img_name):
		self._img_name = img_name
		with open(img_name, 'rb') as file:
			self.MBR = file.read(TRACK_SIZE)
			self.Clusters_table = file.read(TRACK_SIZE)
			for i in range(CLUSTERS_COUNT):
				self.Clusters[i] = file.read(CLUSTER_SIZE * TRACK_SIZE)

	def save(self):
		with open(self._img_name, 'wb') as file:
			file.write(self.MBR)
			file.write(self.Clusters_table)
			for i in range(CLUSTERS_COUNT):
				file.write(self.Clusters[i])

	def load(self, filename, file, cluster=None):
		if len(filename) > FILE_INFO_SIZE - 2:
			raise Exception('Long filename!')
		if cluster is not None:
			self._write_file(filename, file, cluster)
			return
		for i in range(CLUSTERS_COUNT):
			if self.Clusters_table[FILE_INFO_SIZE * i] == 0:
				cluster = i + 1
				break
		if cluster is None:
			print('All clusters are busy. Explicitly indicate which cluster to write the file to.')
			return
		self._write_file(filename, file, cluster)

	def _write_file(self, filename, file, cluster):
		file_info_start = FILE_INFO_SIZE * (cluster - 1)
		if self.Clusters_table[file_info_start] == 255:
			print('There is already a file in this cluster. Overwrite? (y/n)')
			while True:
				overwrite = input('>')
				if overwrite == 'n':
					return
				if overwrite == 'y':
					break
		self._write(file_info_start, filename, file, cluster)
		self.save()

	def _write(self, file_info_start, filename, file, cluster):
		filename = filename.encode('utf8')
		file_info_len = struct.pack('B', len(filename))
		file_info = b'\xff' + file_info_len + filename
		file_info += bytearray(FILE_INFO_SIZE - len(file_info))
		self.Clusters_table = self.Clusters_table[:file_info_start] + file_info \
							  + self.Clusters_table[file_info_start + FILE_INFO_SIZE:]
		to_write = file.read(CLUSTER_VOLUME)
		to_write += bytearray(CLUSTER_VOLUME - len(to_write))
		self.Clusters[cluster - 1] = to_write

	def i_list(self):
		files = []
		for i in range(CLUSTERS_COUNT):
			file = None
			current = i * FILE_INFO_SIZE
			a = self.Clusters_table[current]
			if self.Clusters_table[current] == 255:
				filename_length = self.Clusters_table[current + 1]
				filename = self.Clusters_table[current + 2:current + 2 + filename_length]
				filename = filename.decode('utf8')
				file = (str(i + 1), filename)
			else:
				file = (str(i + 1), '::free::')
			files.append(file)
		return files

	def delete_by_cluster(self, cluster):
		file_info_start = FILE_INFO_SIZE * (cluster - 1)
		self.Clusters_table = self.Clusters_table[:file_info_start] + b'\x00' + self.Clusters_table[file_info_start + 1:]
		self.save()

	def delete_by_name(self, name):
		files = self.i_list()
		for file in files:
			if file[1] == name:
				self.delete_by_cluster(int(file[0]))
				return
		print('File not found')

	def get_cluster_inside(self, cluster):
		return self.Clusters[cluster-1]


def main():
	print('Hello! Input image filename')
	while True:
		img_name = input('>')
		path = abspath(img_name)
		if not exists(path):
			print('The path does not exist!')
			continue
		if not isfile(path):
			print('This is not a file.')
			continue
		filename = basename(path).split('.')
		if filename[-1] != 'img':
			print('This is not .img file!')
			continue
		try:
			image = IMG(img_name)
			break
		except FileNotFoundError:
			print('File not found! Try again')
	run(image)


def run(image):
	while True:
		try:
			message = input('>')
			query = message.split(' ')
			str_command = query[0].lower()

			argument = None
			option = None

			if len(query) == 2:
				argument = query[1]

			if len(query) > 2:
				argument = query[1]
				i = 1
				while argument.endswith('\\'):
					i += 1
					if i == len(query):
						break
					argument = argument[:-1] + ' ' + query[i]
				i += 1
				if i < len(query):
					option = query[i]
					while option.endswith('\\'):
						i += 1
						if i == len(query):
							break
						option = option[:-1] + ' ' + query[i]

			command = COMMANDS.get(str_command, invalid)
			command(image, argument, option)
		except Exception as error:
			print(error)


def i_list(image, arg1, arg2):
	files = image.i_list()
	print('#\t-\tName')
	for i in range(CLUSTERS_COUNT):
		print('\t-\t'.join(files[i]))


def i_del(image, key, value):
	if key == '-c':
		image.delete_by_cluster(int(value))
	elif key == '-n':
		image.delete_by_name(value)
	else:
		print('Unknown key')


def i_load(image, path, cluster=None):
	try:
		cluster = int(cluster)
	except Exception:
		print('Something wrong!')
		return
	path = abspath(path)
	if not exists(path):
		print('The path does not exist!')
		return
	if not isfile(path):
		print('This is not a file.')
		return
	filename = basename(path)
	if getsize(path) > CLUSTER_VOLUME:
		print('File is too big! Write part of the file (9 kb)? (y/n)')
		res = input('>')
		if res == 'n':
			return
	with open(path, 'rb') as file:
		try:
			image.load(filename, file, cluster)
		except Exception as e:
			print(e)


def i_read(image, filename, arg2=None):
	files = image.i_list()
	for file in files:
		if file[1] == filename:
			file_inside = image.get_cluster_inside(int(file[0]))
			if arg2 == '-d':
				print(file_inside.decode())
			else:
				print(file_inside)
			return
	print('File not found!')


def i_help(image, command=None, arg2=None):
	pass


def exit(image, arg1, arg2):
	image.save()
	sys.exit(0)


def invalid(image=None, arg1=None, arg2=None):
	print("Invalid command. Use 'help' command or '/?' for internal help")


COMMANDS = {
	'list': i_list,
	'ls': i_list,
	'dir': i_list,
	'del': i_del,
	'load': i_load,
	'read': i_read,
	'cat': i_read,
	'help': i_help,
	'?': i_help,
	'exit': exit,
	'q': exit
}

if __name__ == '__main__':
	main()
