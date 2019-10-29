ALTER PROCEDURE [transfer].[debit.allocationCalculate]
    @suspenseAccountNumber varchar(50), --account number of AN
	@depositAmount money, -- 
    @floatAccountNumberLimits [core].map READONLY, -- Stores account numbers with limits in format: key = FloatAccountNumber, value = floatAccountLimit
	@meta core.metaDataTT READONLY
AS

-- checks if the user has a right to make the operation
DECLARE @actionID varchar(100) =  OBJECT_SCHEMA_NAME(@@PROCID) + '.' +  OBJECT_NAME(@@PROCID), @return int = 0
EXEC @return = [user].[permission.check] @actionId =  @actionID, @objectId = null, @meta = @meta
IF @return != 0
BEGIN
    RETURN 55555
END

--table to calc used overdraft by float accounts
DECLARE @usedOverdraft table (accountNumber VARCHAR(50), usedOverdraftValue MONEY);

INSERT INTO @usedOverdraft
SELECT 
a.accountNumber, 
(
CAST(fal.[value] as MONEY)  --limit by float account  
-
(b.credit - b.debit) --unsued overdraft
) --used overdraft

FROM  @floatAccountNumberLimits fal
INNER JOIN ledger.account a ON (fal.[key]= a.accountNumber)
INNER JOIN ledger.balance b ON (b.accountId = a.accountId)

DECLARE  @totalOverdraftLimitUsedByAgent MONEY = (SELECT SUM(usedOverdraftValue)FROM  @usedOverdraft)

--return allocations by deposit
SELECT 
@suspenseAccountNumber as 'SourceAccount',
uo.accountNumber as 'DestinationAccount',
(uo.usedOverdraftValue / @totalOverdraftLimitUsedByAgent) * @depositAmount  as 'TransferAmount' 
FROM  @usedOverdraft uo 

GO
