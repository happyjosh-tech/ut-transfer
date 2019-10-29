ALTER PROCEDURE [transfer].[push.confirmLedgerBulk]
    @transferIds core.arrayNumberList READONLY
AS
SET NOCOUNT ON

UPDATE t    
SET ledgerTxState = 2
FROM [transfer].[transfer] t
JOIN @transferIds tids ON tids.value = t.transferId
WHERE ledgerTxState = 1

INSERT INTO [transfer].[event] (eventDateTime, transferId, [type], [state], source, [message])
SELECT SYSDATETIME(), value, 'transfer.push', 'confirm', 'ledger', 'Transfer success'
FROM @transferIds