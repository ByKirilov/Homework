import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-company-info',
  templateUrl: './company-info.component.html',
  styleUrls: ['./company-info.component.css']
})
export class CompanyInfoComponent implements OnInit {

  companyFirstPhoto = "assets/ferret-1.jpg";
  firstPhotoPrice = 42;
  companySecondPhoto = "assets/ferret-2.jpg";
  secondPhotoPrice = 333;
  companyThirdPhoto = "assets/ferret-3.jpg";
  thirdPhotoPrice = 666;

  constructor() { }

  ngOnInit() {
  }

}
