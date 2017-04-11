# dsiEMVX.VB6

* More documentation?  http://developer.vantiv.com
* Questions?  integrationteam@mercurypay.com
* **Feature request?** Open an issue.
* Feel like **contributing**?  Submit a pull request.

##Overview

This repository demonstrates how to integrate to an ActiveX control designed by Datacap Systems, Inc. and used to facilitate U.S. EMV payment card transactions.    This readme will provide information on how to setup the software and hardware to enable EMV transactions and to successfully send:

* EMVParamDownload -- used to pull the proper EMV parameters to the hardware device.
* EMVPadReset -- used to return the device to a ready state and ensure no card has been left in the chip reader.
* EMVSale -- execute a card present EMV chip sale transaction.
* EMVReturn -- execute a card present EMV chip return transaction. 

![dsiEMVX.VB6](https://github.com/mercurypay/dsiEMVX.VB6/blob/master/screenshot.PNG)

##Prerequisites

Please contact your Developer Integrations Analyst for any questions about the below prerequisites.  Details are also outlined in the Datacap integration guide.

* dsiEMVX installed
* Mercury US EMV NETePay installed
* Deployment ID configured in Mercury US EMV NETePay
* Test VeriFone VX805 peripheral device
* Test Chip or Dual Interface card.


##Step 1: Device Configuration

After installing the prerequisites we are now ready to configure the device for EMV capability.  If your device is already EMV capable you can skip this step but it never hurts to send an EMVParamDownload to be certain.  To do this we send an EMVParamDownload command using the dsiEMVX.  This command is sent when a device needs to be provisioned with EMV parameters for the first time or later in the event of parameter updates.

The request looks like this:

```
<TStream>
  <Admin>
    <HostOrIP>127.0.0.1</HostOrIP>
    <IpPort>9000</IpPort>
    <MerchantID>337234005</MerchantID>
    <TranCode>EMVParamDownload</TranCode>
    <SecureDevice>EMV_VX805_MERCURY</SecureDevice>
    <ComPort>9</ComPort>
    <InvoiceNo>1</InvoiceNo>
    <RefNo>1</RefNo>
    <SequenceNo>0010010000</SequenceNo>
  </Admin>
</TStream>
```

Send a request by instantiating the dsiEMVX and then sending the command string using the ProcessTransaction method.

```
dsiEMVX = new DSIEMVXLib.DsiEMVX();
string response = dsiEMVX.ProcessTransaction(txtRequest.Text);
```

A successful response looks like:

```
<?xml version="1.0"?>
<RStream>
	<CmdResponse>
		<ResponseOrigin>Processor</ResponseOrigin>
		<DSIXReturnCode>000000</DSIXReturnCode>
		<CmdStatus>Success</CmdStatus>
		<TextResponse>SUCCESS</TextResponse>
		<SequenceNo>0010010000</SequenceNo>
		<UserTrace></UserTrace>
	</CmdResponse>
	<TranResponse>
		<TranCode>EMVParamDownload</TranCode>
	</TranResponse>
</RStream>
```

##Step 2: Build the EMV Chip Card Transaction Types

Build XML commands and process with dsiEMVX object.  In the sample code we are going to build three different XML requests for the three different transaction types but we will only show the request for the EMV Sale transaction here.  Please see the sample code or the integration guide for further information on the other transaction types.

Below is a sample EMV Sale transaction.

```
<TStream>
  <Transaction>
    <HostOrIP>127.0.0.1</HostOrIP>
    <IpPort>9000</IpPort>
    <MerchantID>337234005</MerchantID>
    <TranCode>EMVSale</TranCode>
    <SecureDevice>EMV_VX805_MERCURY</SecureDevice>
    <ComPort>9</ComPort>
    <InvoiceNo>1</InvoiceNo>
    <RefNo>1</RefNo>
    <Purchase>1.11</Purchase>
    <SequenceNo>0010010000</SequenceNo>
    <RecordNo>RecordNumberRequested</RecordNo>
    <Frequency>OneTime</Frequency>    
  </Transaction>
</TStream>
```

Send this request as we did the EMVParamDownload request above using the dsiEMVX and follow the prompts on the VX805.  You will be prompted to confirm the amount, insert, tap or swipe your test card, and this will be followed with an 'Approved' or 'Declined' message.

##Step 3: Parse the XML Response

Parse the XML Response using any mechanism you wish but in the sample code we use the XMLHelper.ParseXMLResponse(string xmlResponse) method which returns a Dictionary&lt;string, string&gt; making things a little easier to manage.

The ParseXMLResponse method looks like the following:

```
Dictionary<string, string> dictionary = new Dictionary<string, string>();
XmlDocument doc = new XmlDocument();
doc.LoadXml(xmlResponse);
TraverseNodes(doc.ChildNodes, dictionary);
return dictionary;
```

Approved transactions will have a CmdStatus equal to "Approved" or "Success".

Here is the response to the above EMVSale transaction.  You will see that this is an Error which is expected at this time when hitting the Mercury platform.  The 'PrintData' is all you need to print your receipts (simply parse out and print the values between the &lt;LineN&gt;. tags) as all of the required EMV receipt information is supplied.

```
<?xml version="1.0"?>
<RStream>
	<CmdResponse>
		<ResponseOrigin>Server</ResponseOrigin>
		<DSIXReturnCode>100201</DSIXReturnCode>
		<CmdStatus>Error</CmdStatus>
		<TextResponse>Invalid Field - Transaction Type</TextResponse>
		<SequenceNo>0010010000</SequenceNo>
		<UserTrace></UserTrace>
	</CmdResponse>
	<TranResponse>
		<CardType>VISA</CardType>
		<TranCode>EMVSale</TranCode>
		<Amount>
			<Purchase>1.11</Purchase>
		</Amount>
	</TranResponse>
	<PrintData>
		<Line1>.MERCHANT ID: 337234005</Line1>
		<Line2>.</Line2>
		<Line3>.                  SALE                  </Line3>
		<Line4>.</Line4>
		<Line5>.************0010</Line5>
		<Line6>.VISA                 ENTRY METHOD: CHIP</Line6>
		<Line7>.DATE: 05/19/2015  TIME: 21:31:40</Line7>
		<Line8>.</Line8>
		<Line9>.INVOICE: 1                              </Line9>
		<Line10>.</Line10>
		<Line11>.AMOUNT                       USD$ 1.11</Line11>
		<Line12>.                            ==========</Line12>
		<Line13>.TOTAL                        USD$ 1.11</Line13>
		<Line14>.</Line14>
		<Line15>.        TRANSACTION NOT COMPLETED       </Line15>
		<Line16>.</Line16>
		<Line17>.Application Label: Visa Credit</Line17>
		<Line18>.AID: A0000000031010</Line18>
		<Line19>.TVR: 0000008000</Line19>
		<Line20>.IAD: 06010A03250000</Line20>
		<Line21>.TSI: E800</Line21>
		<Line22>.ARC: Z3</Line22>
		<Line23>.CVM: NONE</Line23>
	</PrintData>
</RStream>

```

###©2015 Mercury Payment Systems, LLC - all rights reserved.

Disclaimer:
This software and all specifications and documentation contained herein or provided to you hereunder (the "Software") are provided free of charge strictly on an "AS IS" basis. No representations or warranties are expressed or implied, including, but not limited to, warranties of suitability, quality, merchantability, or fitness for a particular purpose (irrespective of any course of dealing, custom or usage of trade), and all such warranties are expressly and specifically disclaimed. Mercury Payment Systems shall have no liability or responsibility to you nor any other person or entity with respect to any liability, loss, or damage, including lost profits whether foreseeable or not, or other obligation for any cause whatsoever, caused or alleged to be caused directly or indirectly by the Software. Use of the Software signifies agreement with this disclaimer notice.
