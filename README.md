# UT Transfer

## Scope

## Integrations

Implement the business logic for reliable transfers, while integrating with the
following modules:

- anti money laundering module (ut-aml)
- alerts and notifications module (ut-alert)
- rules module (ut-rule)
- core banking System
- ATM module (ut-atm)
- POS module (ut-pos)
- utility companies for bill payments
- mobile network operators for top up
- EFT switches via ISO 8583
- card transactions pre-processing modules (ut-ctp-*)

## Definitions

- __Acquirer__ - the front end that captured the transfer parameters, for example:
  - agent application
  - teller application
  - end user application
  - ATM
  - POS
- __Issuer__ - the institution of the account holder of the source account of
  the transfer, for example:
  - local core banking system
  - remote core banking system
- __Merchant__ - third party participating in the transfer, for example:
  - MNO
  - electricity company
  - ISP
  - cable operator
  - retailer

## Transfer types

The following minimum set of transfer types should be supported:

- cash in / deposit
- cash out / withdrawal
- funds transfer / push transfer to own account
- funds transfer / push transfer to account in the same ledger
- funds transfer / push transfer to account in foreign ledger
- mobile airtime top up
- bill payment
- cheque deposit / payment / etc...
- loan disbursement
- loan repayment
- currency exchange
- group collection sheet
- sale
- receive money
- till transactions

## Enquiries

- balance
- mini statement

## Pending transactions

## Standing / scheduled / periodic transactions

## Reversals

## Reconciliation

## Settlement

## Store And Forward (SAF) / Stand-in mode

## Modules

The functionality is split in the following sub-modules:

- _transferFlow_
- _currency_

  **NOTE: each module includes _PUBLIC_ and _PRIVATE_ methods, as noted below**

## transferFlow API

### start - _PUBLIC_

()

Initializes the global variables of the sub-module:

- _errors_ (object) - contains _transfer_ errors that could be encountered by
 _ut-transfer_
- _idlePorts_ (set) - ???

### transferFlow.rule.validate - _PUBLIC_

(params)

???

params

- _params_ (???) - ???

result - ???

### transferFlow.push.execute - _PUBLIC_

(params)

Performs transaction processing operations in DB

params (object)

- _abortAcquirer_ (object) - error details; **NOTE: available only if an error
 has been encountered during trasnaction processing**
  - _message_ (string) - error message
  - _method_ (array) - method sequence in which the error was encountered
    - (string) - method name
  - _params_ (object) - error details; **NOTE: content is different for each error**
- _acquirerCode_ (???) - ??? :null
- _amount_ (object) - transaction amount details
  - _transfer_ (object) - transaction amount details
    - _amount_ (number) - transaction amount
    - _cents_ (integer) - transaction amount in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
- _cardId_ (string) - card ID from DB
- _cardNumber_ (string) - the last 4 digits of the card number
- _cardProductName_ (string) - name of the card product
- _channelId_ (string) - terminal ID from DB
- _channelType_ (string) - type of the channel/device from which the
 transaction was requested; __Valid values__: _atm_, ???
- _credentialId_ (string) - masked card number defined by PCI Security Standard
 (__BIN__ + __****__ + __last 4 digits__)
- _description_ (string) - transaction type; __Valid values__: _atm balance_, ???
- _destinationAccount_ (string) - destination account number; **NOTE:
 available only if the transaction type (_description_) is ???**
- _destinationAccountName_ (string) - name of the _destinationAccount_ type
- _destinationType_ (string) - ??? "actorId"; __Valid values__: ???
- _expireSeconds_ (integer) - ??? 90
- _issuerId_ (string) - partner ID from DB
- _ledgerId_ (string) - ??? "cbs"
- _merchantId_ (string) - merchant ID from DB
- _merchantType_ (string) - merchant type from DB
- _mode_ (string) - ??? "default"; __Valid values__: ???
- _ordererId_ (???) - ??? :undefined
- _pinBlock_ (string) - PIN block
- _pinCheckValueNew_ (string) - new PIN check value; **NOTE: contains either
 IBM PIN offset or VISA PVV, depending on card settings**; **NOTE: available
 only if PIN change transaction has been performed**
- _reversed_ (bool) - flag if the transaction has been reversed
- _skipLedger_ (???) - ??? :undefined
- _sourceAccount_ (string) - source account number ??? :"selected:1"
- _sourceAccountName_ (string) - name of the _sourceAccount_ type
- _sourceCardProductId_ (string) - card product ID from DB
- _tpk_ (string) - Terminal PIN Key under LMK
- _transferIdAcquirer_ (integer) - acquirer ID of the transaction
- _transferType_ (string) - transaction type; __Valid values__: _deposit_,
 _withdraw_, _withdrawOtp_, _transfer_, _transferOtp_, _balance_,
 _ministatement_, _topup_, _checkbook_, _bill_, _sale_, _sms_, _changePin_,
 _loanDisburse_, _loanRepay_, _forex_, _accountList_, _tia_
- _udfAcquirer_ (object) - user defined fields ???
  - _arqcFail_ (bool) - flag if the Authorization Request Cryptogram
   verification has failed
  - _cardFlow_ (string) - ??? :"own"
  - _emvData_ (object) - if the current EMV tag is NOT a DOL tag, each
   _key: value_ pair contains the following:
    - _key_ - EMV tag key
    - _value_ (string) - EMV tag value
  - _emvData_ (object) - if the current EMV tag is a DOL tag, each _key:
   value_ pair contains the following:
    - _key_ - EMV tag key
    - _value_ (object) - EMV tag object
      - _tag_ (string) - EMV tag
      - _val_ (string) - EMV tag value; **NOTE: as the value of a DOL tag
       does not contain values for nested tags, this is usually ''**
      - _len_ (integer) - length of _val_ in bytes
      - _idx_ (integer) - position of the tag in the DOL
  - _entryMode_ (string) - point of service entry mode meaning as defined in
   ISO 8583
  - _fallbackMode_ (???) - ??? :undefined
  - _identificationCode_ (string) - identification code from DB
  - _isEmvCard_ (bool) - flags if the transaction contains EMV data
  - _isFallBack_ (bool) - flags if the transaction is performed with ICC
  - _isLastFallback_ (bool) - ??? :false
  - _isOwnCard_ (bool) - flags if the card issuer is the same as the terminal owner
  - _mti_ (integer) - ISO8583 message type identificator
  - _opcode_ (string) - operation code data as defined in _APTRA Advance NDC,
   Reference Manual_
  - _pan_ (string) - encrypted card number
  - _processingCode_ (string) - ISO8583 processing code
  - _terminalId_ (string) - terminal ID from DB
  - _terminalName_ (string) - terminal address from DB
  - _track2_ (string) - encrypted track 2 data from magnetic stripe
  - _track2EquivalentData_ (string) - encrypted track 2 equivalent data EMV tag

result (object)

- _abortAcquirer_ (object) - error details; **NOTE: available only if an
  error has been encountered during trasnaction processing**
  - _message_ (string) - error message
  - _method_ (array) - method sequence in which the error was encountered
    - (string) - method name
  - _params_ (object) - error details; **NOTE: content is different for each error**
- _acquirerCode_ (???) - ??? :null
- _acquirerFee_ (integer) - fee to be paid to the transaction acquirer
- _actualAmount_ (???) - ??? :undefined
- _actualAmountCurrency_ (???) - ??? :undefined
- _amount_ (object) - transaction amount details
  - _transfer_ (object) - transaction amount details
    - _amount_ (number) - transaction amount
    - _cents_ (integer) - transaction amount in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
  - _acquirerFee_ (object) - acquirer fee details
    - _amount_ (string) - transaction amount
    - _cents_ (integer) - transaction amount in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
  - _issuerFee_ (object) - issuer fee details
    - _amount_ (string) - transaction amount
    - _cents_ (integer) - transaction amount in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
  - _processorFee_ (object) - processor fee details
    - _amount_ (string) - transaction amount
    - _cents_ (integer) - transaction amount in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
- _balance_ (object) - details of the account balance
  - _ledger_ (object) - details of the ledger balance
    - _amount_ (string) - ledger account balance
    - _cents_ (integer) - ledger account balance in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
  - _available_ (object) - details of the available balance
    - _amount_ (string) - available account balance
    - _cents_ (integer) - available account balance in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
- _cardId_ (string) - card ID from DB
- _cardNumber_ (string) - the last 4 digits of the card number
- _cardProductName_ (string) - name of the card product
- _channelId_ (string) - terminal ID from DB
- _channelType_ (string) - type of the channel/device from which the
  transaction was requested; __Valid values__: _atm_, ???
- _credentialId_ (string) - masked card number defined by PCI Security
  Standard (__BIN__ + __****__ + __last 4 digits__)
- _description_ (string) - transaction type; __Valid values__: _atm
  balance_, ???
- _destinationAccount_ (string) - destination account number; **NOTE:
  available only if the transaction type (_description_) is ???**
- _destinationAccountName_ (string) - name of the _destinationAccount_ type
- _destinationType_ (string) - ??? "actorId"; __Valid values__: ???
- _expireSeconds_ (integer) - ??? 90
- _issuerEmv_ (???) - ??? :undefined
- _issuerFee_ (number) - fee to be paid to the issuer
- _issuerId_ (string) - partner ID from DB
- _issuerPort_ (string) - UT5 port associated with the _issuerId_
- _issuerRequestedDateTime_ (date/string) - ??? "2019-06-18T11:14:07.047Z"
- _issuerSerialNumber_ (string) - ??? "66"
- _issuerSettlementDate_ (string) - ??? "20170116103007"
- _ledgerId_ (string) - ??? "cbs"
- _ledgerPort_ (string) - ??? "t24/transfer"
- _localDateTime_ (string) - ??? "20190618141406"
- _merchantId_ (???) - ??? null
- _merchantPort_ (???) - ??? null
- _merchantType_ (???) - ??? null
- _mode_ (string) - ??? "default"; __Valid values__: ???
- _ordererId_ (???) - ??? null
- _pinBlock_ (string) - PIN block
- _pinCheckValueNew_ (string) - new PIN check value; **NOTE: contains either
  IBM PIN offset or VISA PVV, depending on card settings**; **NOTE: available
  only if PIN change transaction has been performed**
- _processorFee_ (number) - fee to be paid to the processor
- _retrievalReferenceNumber_ (string) - transaction ID defined by ??? :undefined
- _reversed_ (bool) - flag if the transaction has been reversed
- _settlementDate_ (???) - ??? :undefined
- _skipLedger_ (???) - ??? :undefined
- _sourceAccount_ (string) - source account number
- _sourceAccountName_ (string) - name of the _sourceAccount_ type
- _sourceCardProductId_ (string) - card product ID from DB
- _split_ (array) - ???
- _tpk_ (string) - Terminal PIN key encrypted under LMK
- _transferAmount_ (number) - amount of the transaction
- _transferCurrency_ (string) - ISO 4217 currency code
- _transferDateTime_ (string/date) - ??? "2019-06-18T14:14:06.650Z"
- _transferFee_ (number) - transaction fee
- _transferId_ (string) - transfer ID from DB
- _transferIdAcquirer_ (integer) - acquirer ID of the transaction
- _transferIdIssuer_ (string) - ??? "cbs"
- _transferType_ (string) - transaction type; __Valid values__: _deposit_,
  _withdraw_, _withdrawOtp_, _transfer_, _transferOtp_, _balance_,
  _ministatement_, _topup_, _checkbook_, _bill_, _sale_, _sms_, _changePin_,
  _loanDisburse_, _loanRepay_, _forex_, _accountList_, _tia_
- _transferTypeId_ (string) - ID of the _transactionType_ from DB
- _udfAcquirer_ (object) - user defined fields ??? TODO: check if the
 structure is the same for all transaction types ???
  - _arqcFail_ (bool) - flag if the Authorization Request Cryptogram
   verification has failed
  - _cardFlow_ (string) - ??? :"own"
  - _emvData_ (object) - if the current EMV tag is NOT a DOL tag, each
   _key: value_ pair contains the following:
    - _key_ - EMV tag key
    - _value_ (string) - EMV tag value
  - _emvData_ (object) - if the current EMV tag is a DOL tag, each _key:
   value_ pair contains the following:
    - _key_ - EMV tag key
    - _value_ (object) - EMV tag object
      - _tag_ (string) - EMV tag
      - _val_ (string) - EMV tag value; **NOTE: as the value of a DOL tag
      does not contain values for nested tags, this is usually ''**
      - _len_ (integer) - length of _val_ in bytes
      - _idx_ (integer) - position of the tag in the DOL
  - _entryMode_ (string) - point of service entry mode meaning as defined in
   ISO 8583
  - _fallbackMode_ (???) - ??? :undefined
  - _identificationCode_ (string) - identification code from DB
  - _isEmvCard_ (bool) - flags if the transaction contains EMV data
  - _isFallBack_ (bool) - flags if the transaction is performed with ICC
  - _isLastFallback_ (bool) - ??? :false
  - _isOwnCard_ (bool) - flags if the card issuer is the same as the terminal owner
  - _mti_ (integer) - ISO8583 message type identificator
  - _opcode_ (string) - operation code data as defined in _APTRA Advance
   NDC, Reference Manual_
  - _pan_ (string) - encrypted card number
  - _processingCode_ (string) - ISO8583 processing code
  - _terminalId_ (string) - terminal ID from DB
  - _terminalName_ (string) - terminal address from DB
  - _track2_ (string) - encrypted track 2 data from magnetic stripe
  - _track2EquivalentData_ (string) - encrypted track 2 equivalent data EMV tag
- _udfIssuer_ (object) - ???

### transferFlow.pending.pullExecute - _PUBLIC_

(params)

???

params

- _params_ (???) - ???

result - ???

### transferFlow.pending.pushExecute - _PUBLIC_

(params)

???

params

- _params_ (???) - ???

result - ???

### transferFlow.idle.execute - _PUBLIC_

(params)

Performs transaction reversal processing

params (object)

- _interval_ (integer) - _interval_ from _parms_
- _issuerPort_ (string) - ???
- _length_ (integer) - ???

result - _true_ or _false_ depending on existence of previous not completed
 execution of _transferFlow.idle.execute_, or presence of transactions pending
 reversal in DB

### transferFlow.push.reverse - _PUBLIC_

(params)

???

params

- _params_ (???) - ???

result - ???

### transferFlow.card.execute - _PUBLIC_

(params)

Performs card transaction processing

params (object)

- _abortAcquirer_ (object) - error details; **NOTE: available only if an error
 has been encountered during trasnaction processing**
  - _message_ (string) - error message
  - _method_ (array) - method sequence in which the error was encountered
    - (string) - method name
  - _params_ (object) - error details; **NOTE: content is different for each error**
- _acquirerCode_ (???) - ??? :null
- _amount_ (object) - transaction amount details
  - _transfer_ (object) - transaction amount details
    - _amount_ (number) - transaction amount
    - _cents_ (integer) - transaction amount in cents
    - _currency_ (string) - ISO 4217 currency code
    - _scale_ (integer) - ISO 4217 currency exponent
- _cardId_ (string) - card ID from DB
- _channelId_ (string) - terminal ID from DB
- _channelType_ (string) - type of the channel/device from which the
 transaction was requested; __Valid values__: _atm_, ???
- _credentialId_ (string) - masked card number defined by PCI Security Standard
 (__BIN__ + __****__ + __last 4 digits__)
- _description_ (string) - transaction type; __Valid values__: _atm balance_, ???
- _destinationType_ (string) - ??? "actorId"; __Valid values__: ???
- _expireSeconds_ (integer) - ??? 90
- _merchantId_ (string) - merchant ID from DB
- _merchantType_ (string) - merchant type from DB
- _mode_ (string) - ??? "default"; __Valid values__: ???
- _ordererId_ (???) - ??? :undefined
- _pinBlock_ (string) - PIN block
- _pinCheckValueNew_ (string) - new PIN check value; **NOTE: contains either
 IBM PIN offset or VISA PVV, depending on card settings**; **NOTE: available
 only if PIN change transaction has been performed**
- _reversed_ (bool) - flag if the transaction has been reversed
- _skipLedger_ (???) - ??? :undefined
- _sourceAccount_ (string) - source account number ??? :"selected:1"
- _tpk_ (string) - Terminal PIN Key under LMK
- _transferType_ (string) - transaction type; __Valid values__: _deposit_,
 _withdraw_, _withdrawOtp_, _transfer_, _transferOtp_, _balance_,
 _ministatement_, _topup_, _checkbook_, _bill_, _sale_, _sms_, _changePin_,
 _loanDisburse_, _loanRepay_, _forex_, _accountList_, _tia_
- _udfAcquirer_ (object) - user defined fields ???
  - _arqcFail_ (bool) - flag if the Authorization Request Cryptogram
   verification has failed
  - _cardFlow_ (string) - ??? :"own"
  - _emvData_ (object) - if the current EMV tag is NOT a DOL tag, each
   _key: value_ pair contains the following:
    - _key_ - EMV tag key
    - _value_ (string) - EMV tag value
  - _emvData_ (object) - if the current EMV tag is a DOL tag, each _key:
   value_ pair contains the following:
    - _key_ - EMV tag key
    - _value_ (object) - EMV tag object
      - _tag_ (string) - EMV tag
      - _val_ (string) - EMV tag value; **NOTE: as the value of a DOL tag
       does not contain values for nested tags, this is usually ''**
      - _len_ (integer) - length of _val_ in bytes
      - _idx_ (integer) - position of the tag in the DOL
  - _entryMode_ (string) - point of service entry mode meaning as defined in
   ISO 8583
  - _fallbackMode_ (???) - ??? :undefined
  - _identificationCode_ (string) - identification code from DB
  - _isEmvCard_ (bool) - flags if the transaction contains EMV data
  - _isFallBack_ (bool) - flags if the transaction is performed with ICC
  - _isLastFallback_ (bool) - ??? :false
  - _isOwnCard_ (bool) - flags if the card issuer is the same as the terminal owner
  - _mti_ (integer) - ISO8583 message type identificator
  - _opcode_ (string) - operation code data as defined in _APTRA Advance NDC,
   Reference Manual_
  - _pan_ (string) - encrypted card number
  - _processingCode_ (string) - ISO8583 processing code
  - _terminalId_ (string) - terminal ID from DB
  - _terminalName_ (string) - terminal address from DB
  - _track2_ (string) - encrypted track 2 data from magnetic stripe
  - _track2EquivalentData_ (string) - encrypted track 2 equivalent data EMV tag

result - result from _transferFlow.push.execute_ method

### transferFlow.transfer.get - _PUBLIC_

(msg, $meta)

???

params

- _params_ (???) - ???
- _$meta_ (object) - meta object as defined in ???

result - ???

### transferFlow.pendingUserTransfers.fetch - _PUBLIC_

(msg, $meta)

???

params

- _params_ (???) - ???
- _$meta_ (object) - meta object as defined in ???

result - ???

### processReversal - _PRIVATE_

(bus, log, $meta, transfer)

???

params

- _bus_ (???) - ???
- _log_ (???) - ???
- _$meta_ (object) - meta object as defined in ???
- _transfer_ (???) - ???

result - ???

### processAdjustment - _PRIVATE_

(bus, log, $meta, transfer)

???

params

- _bus_ (???) - ???
- _log_ (???) - ???
- _$meta_ (object) - meta object as defined in ???
- _transfer_ (???) - ???

result - ???

### processAny - _PRIVATE_

(bus, log, $meta)(transfer)

???

params

- _bus_ (???) - ???
- _log_ (???) - ???
- _$meta_ (object) - meta object as defined in ???
- _transfer_ (???) - ???

result - ???

### ruleValidate - _PRIVATE_

(bus, transfer)

???

params

- _bus_ (???) - ???
- _transfer_ (???) - ???

result - ???

### hashTransferPendingSecurityCode - _PRIVATE_

(bus, transfer)

???

params

- _bus_ (???) - ???
- _transfer_ (???) - ???

result - ???

## currency API

### _numeric_ - _PUBLIC_

Sends request to _numeric_ _PRIVATE_ function

### _alphabetic_ - _PUBLIC_

Sends request to _alphabetic_ _PRIVATE_ function

### _scale_ - _PUBLIC_

Sends request to _getScale_ _PRIVATE_ function

### _cents_ - _PUBLIC_

(currency, cents, sign)

Prepares amount object for transaction processing ???

params

- _currency_ (string) - ISO 4217 alphabetic or numeric currency code
- _cents_ (string) - amount in cents
- _sign_ (integer) - amount sign; __Valid values__: _1_, _-1_; __Default__: _1_

result - result from _amountObject_ method

### _amount_ - _PUBLIC_

(currency, amount, sign)

Prepares amount object for transaction processing ???

params

- _currency_ (string) - ISO 4217 currency code
- _amount_ (integer) - amount
- _sign_ (integer) - amount sign; __Valid values__: _1_, _-1_; __Default__: _1_

result - result from _amountObject_ method

### _alphabetic_ - _PRIVATE_

(code)

Checks if _code_ is valid ISO 4217 alphabetic currency code

params

- _code_ (string) - ISO 4217 currency code

result - depending on _code_:

- (string) - _code_ if _code_ is a valid ISO 4217 alphabetic currency code

OR

- (string) - ISO 4217 alphabetic currency code otherwise; **NOTE: presumably
 _code_ is a valid numeric currency code in that case**

### _numeric_ - _PRIVATE_

(code)

Checks if _code_ is valid ISO 4217 numeric currency code

params

- _code_ (string) - ISO 4217 currency code

result - depending on _code_:

- (string) - _code_ if _code_ is a valid ISO 4217 numeric currency code

OR

- (string) - ISO 4217 numeric currency code otherwise; **NOTE: presumably
 _code_ is a valid alphabetic currency code in that case**

### _amountObject_ - _PRIVATE_

(cents, scale, sign, currency, string)

Creates amount object for transaction processing

params

- _cents_ (string) - amount in cents
- _scale_ (integer) - ISO 4217 currency exponent
- _sign_ (integer) - amount sign; __Valid values__: _1_, _-1_; __Default__: _1_
- _currency_ (string) - ISO 4217 currency code
- _string_ (string) - amount; **NOTE: used only if error is encountered**

result (object)

- _amount_ (string) - amount
- _cents_ (integer) - amount in cents with _sign_ applied
- _currency_ (string) - ISO 4217 alphabetic currency code
- _scale_ (integer) - currency exponent

### _roundCents_ - _PRIVATE_

(value, exp)

???

params

- _value_ (integer) - amount
- _exp_ (integer) - ISO 4217 currency exponent

result

- (integer) - ???

### _getScale_ - _PRIVATE_

(code)

Returns ISO 4217 currency exponent

params

- _code_ (string) - ISO 4217 alphabetic or numeric currency code

result

- (integer) - ISO 4217 currency exponent of the provided currency

## Currency dictionaries

The following currency dictionaries are present in the _currency_ module (data
 from [currency-iso](http://www.currency-iso.org/en/home/tables/table-a1.html)):

- _ALPHABETIC_ - each _key: value_ pair has the following structure:
  - _key_ - ISO 4217 alphabetic currency code
  - _value_ (string) - ISO 4217 numeric currrency code
- _NUMERIC_ - each _key: value_ pair has the following structure:
  - _key_ - ISO 4217 numeric currency code
  - _value_ (string) - ISO 4217 alphabetic currrency code
- _SCALE_ - each _key: value_ pair has the following structure:
  - _key_ - ISO 4217 numeric OR alphabetic currency code; **NOTE: both numeric
   AND alphabetic currency codes are available for each currency**
  - _value_ (integer) - currency exponent as defined in ISO 4217

### transfer.push.execute(params)

* **params.transferType** - type of the transfer. Transfer types are items in
  the **core.itemName** table, with itemTypeId pointing to
  table **core.itemType** and row with alias='operation'. The follwing values
  for **core.itemName.itemTypeCode** are predefined:
  * **deposit** - Deposit / cash in
  * **withdraw** - Withdraw / cash out
  * **withdrawOtp** - Withdraw with OTP
  * **transfer** - Funds transfer to account
  * **transferOtp** - Funds transfer with OTP
  * **balance** - Balance enquiry
  * **ministatement** - Mini statement enquiry
  * **topup** - Top up
  * **bill** - Bill payment
  * **sale** - Sale
  * **sms** - SMS registration
  * **changePin** - PIN change
  * **loanDisburse** - Loan disbursement
  * **loanRepay** - Loan repayment
  * **forex** - Foreign currency exchange
* **params.transferIdAcquirer** - id assigned to the transfer by the acquirer
* **params.transferDateTime** - the time transfer was recorded in the database
* **params.channelId** - actor id of the channel
* **params.channelType** - type of the channel: atm, pos, teller, agent,
* **params.ordererId** - id of the actor ordering the transaction. In case of
  card transaction this is the card holder.
* **params.merchantId** - identifier of the merchant (partnerId from the
  transfer.partner table)
* **params.merchantInvoice** - identifier suitable to be sent to the merchant
  for processing the operation. In addition to invoice number, can also be
  phone number, contract numner, etc.
* **params.merchantType** - type of merchant (for ISO use)
* **params.cardId** - card id of the card (in case of card transaction)
* **params.sourceAccount** - account number of the source account
* **params.destinationAccount** - account number of the destination account
* **params.issuerId** - identifier of the issuer (partnerId from the
  transfer.partner table)
* **params.ledgerId** - identifier of the ledger, where transfer should also be
  posted (defaults to 'cbs')
* **params.transferCurrency** - alphabetic currency code
* **params.transferAmount** - amount of the transfer
* **params.acquirerFee** - fee to be paid to the acquirer, debited from the
  source account in addition to the transfer amount
* **params.issuerFee** - fee to be paid to the issuer, debited from the source
  account in addition to the transfer amount
* **params.transferFee** - fee to be paid to the switch, debited from the source
  account in addition to the transfer amount
* **params.description** - text description for the transfer
* **params.udfAcquirer** - additional user defined fields related to the
  acquirer. Example of such fields are:
  * **terminalId** - ATM/POS terminal id, ISO 8583 field 41
  * **identificationCode** - ISO 8583 field 42r
  * **terminalName** - name and location of the terminal, ISO 8583 field 43
  * **opcode** - ATM operation code buffer
  * **processingCode** - ISO 8583 field 3
  * **merchantType** - ISO 8583 field 18
  * **institutionCode** - ISO 8583 field 32
* **params.udfIssuer** - additional user defined fields related to the issuer
* **params.udfTransfer** - additional user defined fields related to the transfer

Upon success returns similar **result** object with the following additional fields:

* **result.transferId** - id assigned to the transfer in the transfer module database
* **result.transferTypeId** - id of the transfe type
* **result.localDateTime** - same as transferDateTime, but formatted as YYYYMMDDhhmmss
* **result.balance** - balance of the source account after successful completion
* **result.transferIdIssuer** - id assigned to the transfer by the issuer
* **result.transferIdMerchant** - id assigned to the transfer by the merchant

In addition the following fields are maintained in the database

* **expireTime** - time at which the transfer can be reversed if not yet completed
* **expireCount** - number of reversal attempts
* **reversed** - set to 1 for reversed accounts
* **retryTime** - time of the last retry (store and forward)
* **retryCount** - count of retries (store and forward)
* **issuerTxState** - transfer state at issuer
* **acquirerTxState** - transfer state at acquirer
* **merchantTxState** - transfer state at merchant
* **issuerErrorType** - error type that happened when executing the operation
  at the issuer
* **issuerErrorMessage** - error message returned when the executing the
  operation at the issuer
* **reversalErrorType** - error type that happened when reversing the operation
  at the issuer
* **reversalErrorMessage** - error message returned when the reversing the
  operation at the issuer
* **acquirerErrorType** - error type that happened when executing the operation
  at the acquirer
* **acquirerErrorMessage** - error message returned when the executing the
  operation at the acquirer
* **merchantErrorType** - error type that happened when processing at the merchant
* **merchantErrorMessage** - error message returned when the executing the
  operation at the merchant

## Dictionaries

### Transaction states

- _1_ - _Request was sent_
- _2_ - _Request was confirmed_
- _3_ - _Request was denied_
- _4_ - _Request timed out or ended with unknown error_
- _5_ - _Request was aborted before any response was received_
- _6_ - _Unexpected error condition_
- _7_ - _Store was requested_
- _8_ - _Store was confirmed_
- _9_ - _Store timed out or returned unknown error_
- _11_ - _Forward was requested_
- _12_ - _Forward was confirmed_
- _13_ - _Forward was denied_
- _14_ - _Forward timed out or returned unknown error_
