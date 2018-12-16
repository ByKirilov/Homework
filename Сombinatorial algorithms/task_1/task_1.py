Edges_weights = {}
Edges = set()
Nodes = {}
Final_graph = []
Graph_weight = 0

i_name = {}
i_next = {}
i_size = {}


def get_data():
    global Nodes, Edges
    with open('in.txt', 'r') as f:
        arr_length = int(f.readline())
        arr = f.read().replace('\n', ' ').split(' ')
        for i in range(arr_length):
            index = int(arr[i]) - 1
            next_index = int(arr[i+1]) - 1
            if arr[index] == '32767':
                return
            name = str(int(i) + 1)
            Nodes[name] = []
            for j in range(index, next_index, 2):
                tmp = frozenset({name, arr[j]})
                Edges.add(tmp)
                Edges_weights[tmp] = int(arr[j+1])


def write_result():
    with open('out.txt', 'w') as f:
        for n in Nodes:
            f.write(f'{n} ' + ' '.join(Nodes[n]) + '\n')
        f.write(str(Graph_weight))


def merge(v, w, p, q):
    global i_name, i_next, i_size
    i_name[w] = p
    u = i_next[w]
    while i_name[u] != p:
        i_name[u] = p
        u = i_next[u]
    i_size[p] += i_size[q]
    i_next[v], i_next[w] = i_next[w], i_next[v]


def find_core():
    global Edges, Nodes, Final_graph, Graph_weight, i_name, i_next, i_size
    Edges = list(Edges)
    Edges.sort(key=lambda e: -Edges_weights[e])
    for n in Nodes:
        i_name[n] = n
        i_next[n] = n
        i_size[n] = 1
    while len(Final_graph) != len(Nodes) - 1:
        edge = list(Edges.pop())
        v = edge[0]
        w = edge[1]
        p = i_name[v]
        q = i_name[w]
        if p != q:
            if i_size[p] > i_size[q]:
                merge(w, v, q, p)
            else:
                merge(v, w, p, q)
            Final_graph.append(edge)
            Nodes[v].append(w)
            Nodes[w].append(v)
            Graph_weight += Edges_weights[frozenset(edge)]
    for n in Nodes.values():
        n.sort(key=lambda x: int(x))
        n.append('0')


if __name__ == '__main__':
    get_data()
    find_core()
    write_result()
