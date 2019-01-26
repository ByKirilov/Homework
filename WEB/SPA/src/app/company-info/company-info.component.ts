import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-company-info',
  templateUrl: './company-info.component.html',
  styleUrls: ['./company-info.component.css']
})
export class CompanyInfoComponent implements OnInit {

  companyFirstPhoto = "assets/lake.jpg";
  firstPhotoPrice = 123;
  companySecondPhoto = "assets/field.jpg";
  secondPhotoPrice = 456;
  companyThirdPhoto = "assets/road.jpg";
  thirdPhotoPrice = 789;

  constructor() { }

  ngOnInit() {
  }

}
