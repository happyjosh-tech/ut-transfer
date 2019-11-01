
MERGE INTO
    [user].[actionCategory] as target
USING
    (VALUES
        ('transfer')
    ) AS source (name)
ON
    target.name=source.name
WHEN NOT MATCHED BY TARGET THEN
INSERT
    ([name])
VALUES
    (source.[name]);

MERGE INTO
    [user].[action] as target
USING
    (VALUES
        ('transfer.partner.fetch', 'transfer.partner.fetch', '{}'),
        ('transfer.partner.list', 'transfer.partner.list', '{}'),
        ('transfer.partner.get', 'transfer.partner.get', '{}'),
        ('transfer.partner.add', 'transfer.partner.add', '{}'),
        ('transfer.partner.edit', 'transfer.partner.edit', '{}'),
       
        ('transfer.pending.cancel', 'transfer.pending.cancel', '{}'),
        ('transfer.pending.reject', 'transfer.pending.reject', '{}'),
        ('transfer.pendingUserTransfers.fetch', 'transfer.pendingUserTransfers.fetch', '{}'),        
        ('transfer.push.create', 'transfer.push.create', '{}'),        
        ('transfer.push.reverse', 'transfer.push.reverse', '{}'),
        ('transfer.push.approve', 'transfer.push.approve', '{}'),         
        ('transfer.report.byDayOfWeek', 'transfer.report.byDayOfWeek', '{}'),
        ('transfer.report.byHourOfDay', 'transfer.report.byHourOfDay', '{}'),
        ('transfer.report.byTypeOfTransfer', 'transfer.report.byTypeOfTransfer', '{}'),
        ('transfer.report.byWeekOfYear', 'transfer.report.byWeekOfYear', '{}'),
        ('transfer.report.settlement', 'transfer.report.settlement', '{}'),
        ('transfer.report.settlementDetails', 'transfer.report.settlementDetails', '{}'),
        ('transfer.report.transfer', 'transfer.report.transfer', '{}'),
        ('transfer.transfer.get', 'transfer.transfer.get', '{}'),
        ('transfer.transferDetails.get', 'transfer.transferDetails.get', '{}'),
        ('transfer.push.reject', 'transfer.push.reject', '{}'),
        ('transfer.push.cancel', 'transfer.push.cancel', '{}'),
        ('transfer.view.foreignAccounts', 'transfer.view.foreignAccounts', '{}')
    ) AS source (actionId, description, valueMap)
JOIN
	[user].[actionCategory] c ON c.name = 'transfer'
ON
    target.actionId=source.actionId
WHEN NOT MATCHED BY TARGET THEN
INSERT
    ([actionId], [actionCategoryId], [description], [valueMap])
VALUES
    (source.[actionId], c.[actionCategoryId], source.[description], source.[valueMap]);


DECLARE @itemNameTranslationTT core.itemNameTranslationTT
DECLARE @meta core.metaDataTT

DECLARE @enLanguageId [tinyint] = (SELECT languageId FROM [core].[language] WHERE iso2Code = 'en');

INSERT INTO @itemNameTranslationTT(itemCode, itemName, itemNameTranslation) 
VALUES  ('cashInToBankAccountAtAgent', 'cashInToBankAccountAtAgent', 'cash In To Bank Account At Agent' )
        
EXEC core.[itemNameTranslation.upload]
    @itemNameTranslationTT = @itemNameTranslationTT,
    @languageId = @enLanguageId,
    @organizationId = NULL,
    @itemType = 'operation',
    @meta = @meta

-- copied from main BA project's ut-transfer

MERGE INTO
    core.itemName AS target
USING
    (VALUES
        ('deposit','Deposit Savings'),
        ('withdraw','Withdrawal Savings'),
        --('withdrawOtp','Withdraw with OTP'),
        ('transfer','Funds transfer to account'),
        --('transferOtp','Funds transfer with OTP'),
        ('balance','Balance Enquiry Savings'),
        ('ministatement','Mini statement enquiry'),
        ('fullstatement', 'Full Statement'),
        --('bill', 'Bill payment'),
        --('sale', 'Sale'),
        --('sms', 'SMS registration'),
        --('changePin', 'PIN change'),
        --('loanDisburse', 'Loan disbursement'),
        ('loanRepay', 'Loan Repayment'),
        --('forex', 'Foreign currency exchange'),
        ('agentMinistatement', 'Agent Mini Statement'),
        ('agentFloatRequest', 'Agent Float Request'),
        ('agentBalance', 'Agent Balance'),
        ('commission', 'Commission'),
        ('paymentCreditCard', 'Payment Credit Card'),
        ('fee', 'Fee'),
        ('depositDM', 'Deposit Current'),
        ('withdrawDM', 'Withdrawal Current'),
        ('withdrawTC', 'Withdrawal Credit Card'),
        ('balanceDM','Balance Enquiry Current'),
        ('balanceTC','Balance Enquiry Credit Card'),
        ('loanRepayCTP', 'Loan Repayment Chepe te Presta'),
        ('loanRepayCP', 'Loan Repayment Compartamos'),
        ('loanRepayGE', 'Loan Repayment Genesis'),
        ('billPaymentEegsa', 'Bill Payment EEGSA'),
        ('billPaymentDeorsa', 'Bill Payment DEORSA'),
        ('billPaymentDeocsa', 'Bill Payment DEOCSA'),
        ('billPaymentEmpagua', 'Bill Payment EMPAGUA'),
        ('billpaymentAirtimeTigoPost', 'Bill Payment TIGO Post Paid'),
        ('billpaymentAirtimeClaroPost', 'Bill Payment CLARO Post Paid'),
        ('billpaymentAirtimeTelefonicaPost', 'Bill Payment TELEFONICA Post Paid'),
        ('billpaymentAirtimeTelefonicaPre', 'Bill Payment TELEFONICA Pre Paid'),
        ('billpaymentAirtimeTigoPre', 'Bill Payment TIGO Pre Paid'),
        ('billpaymentAirtimeClaroPre', 'Bill Payment CLARO Pre Paid'),
        ('mobileCash', 'Mobile Cash'),
        ('remittanceWuVigo', 'Remittance Payment WU - VIGO'),
        ('remittanceMultiBrand', 'Remittance Payment MULTIBRAND')
    ) AS source (itemCode, itemName)
JOIN
	core.itemType t on t.alias='operation'
ON
    target.itemCode = source.itemCode
WHEN MATCHED THEN UPDATE SET target.itemName = source.itemName
WHEN
    NOT MATCHED BY TARGET THEN
INSERT
    (itemTypeId, itemCode, itemName)
VALUES
    (t.itemTypeId, source.itemCode, source.itemName);
