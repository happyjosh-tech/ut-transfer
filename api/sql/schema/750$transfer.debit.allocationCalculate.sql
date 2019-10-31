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

DECLARE @usedOverdraft table (accountNumber VARCHAR(50), usedOverdraftValue MONEY);
DECLARE @allocateAmounts table (sourceAccountNumber VARCHAR(50),destinationAccountNumber VARCHAR(50),  transferAmount MONEY);
DECLARE @totalOverdraftLimitUsedByAgent MONEY
DECLARE @totalLimit MONEY
DECLARE @depositToAllocate MONEY = @depositAmount


--insert used overdraft
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

SET @totalOverdraftLimitUsedByAgent = (SELECT SUM(usedOverdraftValue)FROM  @usedOverdraft)
SET @totalLimit = (SELECT SUM(CAST([value] as MONEY)) FROM @floatAccountNumberLimits) 

IF @depositAmount > @totalLimit
	SET @depositToAllocate = @totalLimit  

--insert allocations by deposit
INSERT INTO @allocateAmounts 
SELECT 
@suspenseAccountNumber ,
uo.accountNumber ,--DestinationAccount
(uo.usedOverdraftValue / @totalOverdraftLimitUsedByAgent) * @depositToAllocate  -- 'TransferAmount'
FROM  @usedOverdraft uo
LEFT JOIN @floatAccountNumberLimits fal ON (uo.accountNumber=fal.[key])

SELECT 'allocations' as resultSetName 
SELECT * from @allocateAmounts 
