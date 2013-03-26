/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestHandleProductPriceChange {

	static testMethod void testPriceChange()  {
		
		// given there is some merch
		Merchandise__c[] products = new Merchandise__c[]{
			new Merchandise__c(Name = 'item 1', Description__c = 'test product 1', Price__c = 10, Total_Inventory__c = 10),
			new Merchandise__c(Name = 'item 2', Description__c = 'test product 2', Price__c = 11, Total_Inventory__c = 10)
		};
		insert products;
		
		// given there is an invoice in 'negotiating'
		Invoice_Statement__c invoice = new Invoice_Statement__c(Status__c = 'Negotiating');
		insert invoice;
		
		// and it contains references to our merch		
		Line_Item__c[] lineItems = new Line_Item__c[] {
			new Line_Item__c(Invoice_Statement__c = invoice.id, Merchandise__c = products[0].id, Unit_Price__c = 10, Units_Sold__c = 3),
			new Line_Item__c(Invoice_Statement__c = invoice.id, Merchandise__c = products[1].id, Unit_Price__c = 11, Units_Sold__c = 6)
		};
		insert lineItems;
		
		// when I alter the price of the merch
		products[0].price__c = 20; // raise price
		products[1].price__c = 5;  // lower price
		Test.startTest();
		update products;
		Test.stopTest(); 
		
		// then the unit price of should have been updated
		lineItems = [SELECT id, unit_price__c FROM Line_Item__c WHERE id IN :lineItems];
		System.assert(lineItems[0].unit_price__c == 10);  // unchanged
		System.assert(lineItems[1].unit_price__c == 5);   // changed!!
		
	}
}