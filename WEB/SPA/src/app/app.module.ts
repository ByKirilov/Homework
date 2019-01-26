import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';

import { AppComponent } from './app.component';
import { PaymentComponent } from './payment/payment.component';
import { ClientInfoComponent } from './client-info/client-info.component';
import { CompanyInfoComponent } from './company-info/company-info.component';

@NgModule({
  declarations: [
    AppComponent,
    PaymentComponent,
    ClientInfoComponent,
    CompanyInfoComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
