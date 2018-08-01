ALTER PROCEDURE [transfer].[payee.list] -- lists all payees for user
    @meta core.metaDataTT READONLY -- information for the user that makes the operation
AS

DECLARE @userId BIGINT = (SELECT [auth.actorId] FROM @meta)

SELECT p.payeeId, p.payeeName, p.accountNumber, p.bankName
FROM [transfer].payee p
WHERE userId = @userId
ORDER BY p.payeeName
