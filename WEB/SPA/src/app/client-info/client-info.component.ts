import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-client-info',
  templateUrl: './client-info.component.html',
  styleUrls: ['./client-info.component.css']
})
export class ClientInfoComponent implements OnInit {
  clientName = "Твоя мамка";
  clientNumber = "+79991234567";
  clientSite = "www.balance.su";
  clientMailAdress = "balance@balance.su";
  clientCompanyInfo = "www.balance.su/info";
  clientRequisites = "www.balance.su/requisites";
  clientLogoPath = "assets/ferret-logo.jpg";


  constructor() { }

  ngOnInit() {
  }

}
