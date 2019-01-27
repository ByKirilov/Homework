import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-client-info',
  templateUrl: './client-info.component.html',
  styleUrls: ['./client-info.component.css']
})
export class ClientInfoComponent implements OnInit {
  clientName = "Твоя мамка";
  clientNumber = "+79991234567";
  clientSite = "www.mamka.com";
  clientMailAdress = "mamka@mamka.com";
  clientCompanyInfo = "www.mamka.com/info";
  clientRequisites = "www.mamka.com/requisites";
  clientLogoPath = "assets/ferret-logo.jpg";


  constructor() { }

  ngOnInit() {
  }

}
