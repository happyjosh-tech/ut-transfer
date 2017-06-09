MERGE INTO
    core.itemName AS target
USING
    (VALUES
        ('deposit','Deposit / cash in'),
        ('withdraw','Withdraw / cash out'),
        ('withdrawOtp','Withdraw with OTP'),
        ('transfer','Funds transfer to account'),
        ('transferOtp','Funds transfer with OTP'),
        ('balance','Balance enquiry'),
        ('ministatement','Mini statement enquiry'),
        ('topup', 'Top up'),
        ('bill', 'Bill payment'),
        ('sale', 'Sale'),
        ('sms', 'SMS registration'),
        ('changePin', 'PIN change'),
        ('loanDisburse', 'Loan disbursement'),
        ('loanRepay', 'Loan repayment'),
        ('forex', 'Foreign currency exchange')
    ) AS source (itemCode, itemName)
JOIN
	core.itemType t on t.alias='operation'
ON
    target.itemCode = source.itemCode
WHEN
    NOT MATCHED BY TARGET THEN
INSERT
    (itemTypeId, itemCode, itemName)
VALUES
    (t.itemTypeId, source.itemCode, source.itemName);

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
        ('db/transfer.partner.fetch', 'db/transfer.partner.fetch', '{}'),
       
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
