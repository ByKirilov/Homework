import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-operations',
  templateUrl: './operations.component.html',
  styleUrls: ['./operations.component.css']
})
export class OperationsComponent implements OnInit {
  isPayScreen = true;
  isRequestPaymentScreen = false;
  PayButtonColor = 'black';
  RequestPaymentButtonColor = 'blue';

  constructor() { }

  ngOnInit() {
  }

  onPayButtonClick() {
    /* TODO: Отображать нужный блок */
    this.isPayScreen = true;
    this.isRequestPaymentScreen = false;
    this.PayButtonColor = 'black';
    this.RequestPaymentButtonColor = 'blue';
  }
  onRequestPaymentButtonButtonClick() {
    /* TODO: Отображать нужный блок */
    this.isPayScreen = false;
    this.isRequestPaymentScreen = true;
    this.PayButtonColor = 'blue';
    this.RequestPaymentButtonColor = 'black';
  }

  getPayButtonColor() {
    return this.PayButtonColor;
  }
  getRequestPaymentButtonColor() {
    return this.RequestPaymentButtonColor;
  }
}
