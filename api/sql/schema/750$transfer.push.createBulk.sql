ALTER PROCEDURE [transfer].[push.createBulk]
    @transfer [transfer].transferTT READONLY,
    @meta core.metaDataTT READONLY
AS
DECLARE @callParams XML

BEGIN TRY

    -- checks if the user has a right to make the operation
    DECLARE @actionID varchar(100) =  OBJECT_SCHEMA_NAME(@@PROCID) + '.' +  OBJECT_NAME(@@PROCID), @return int = 0
    EXEC @return = [user].[permission.check] @actionId =  @actionID, @objectId = null, @meta = @meta
    IF @return != 0
    BEGIN
        RETURN 55555
    END

    IF OBJECT_ID('tempdb..#transfer') IS NOT NULL    
        DROP TABLE #transfer

    IF OBJECT_ID('tempdb..#transferOutput') IS NOT NULL    
        DROP TABLE #transferOutput

    CREATE TABLE #transfer (
    	[transferId] [bigint] NULL, [transferTypeId] [bigint] NULL, [acquirerCode] [varchar](50) NULL, [transferIdAcquirer] [varchar](50) NULL,  [transferIdLedger] [varchar](50) NULL,
	    [transferIdIssuer] [varchar](50) NULL, [transferIdMerchant] [varchar](50) NULL, [transferDateTime] [datetime] NULL, [localDateTime] [varchar](14) NULL, [settlementDate] [date] NULL,
	    [channelId] [bigint] NULL, [channelType] [varchar](50) NULL, [ordererId] [bigint] NULL, [merchantId] [varchar](50) NULL, [merchantInvoice] [varchar](50) NULL, [merchantPort] [varchar](50) NULL,
	    [merchantType] [varchar](50) NULL, [cardId] [bigint] NULL, [sourceAccount] [varchar](50) NULL, [destinationAccount] [varchar](50) NULL, [expireTime] [datetime] NULL, [expireCount] [int] NULL,
	    [reversed] [bit] NULL, [retryTime] [datetime] NULL, [retryCount] [int] NULL, [ledgerTxState] [smallint] NULL, [issuerTxState] [smallint] NULL, [acquirerTxState] [smallint] NULL,
	    [merchantTxState] [smallint] NULL, [issuerId] [varchar](50) NULL, [ledgerId] [varchar](50) NULL, [transferCurrency] [varchar](3) NULL, [transferAmount] [money] NULL, [acquirerFee] [money] NULL,
	    [issuerFee] [money] NULL, [transferFee] [money] NULL, [taxVAT] [money] NULL, [taxWTH] [money] NULL, [taxOther] [money] NULL, [commission] [money] NULL, [description] [varchar](250) NULL,
	    [comment] [nvarchar](250) NULL, [noteToSelf] [nvarchar](250) NULL, [utilityRef] [nvarchar](250) NULL)
    
    CREATE TABLE #transferOutput ([transferId] [bigint] NULL, [sourceAccount] [varchar](50) NULL, [destinationAccount] [varchar](50) NULL, [transferAmount] [money] NULL)    
    
    INSERT INTO #transfer ([transferId], [transferTypeId], [acquirerCode], [transferIdAcquirer], [transferIdLedger], [transferIdIssuer], [transferIdMerchant], [transferDateTime],
        [localDateTime], [settlementDate], [channelId], [channelType], [ordererId], [merchantId], [merchantInvoice], [merchantPort], [merchantType], [cardId], [sourceAccount],
        [destinationAccount], [expireTime], [expireCount], [reversed], [retryTime], [retryCount], [ledgerTxState], [issuerTxState], [acquirerTxState], [merchantTxState],
        [issuerId], [ledgerId], [transferCurrency], [transferAmount], [acquirerFee], [issuerFee], [transferFee], [taxVAT], [taxWTH], [taxOther], [commission], [description],
        [comment], [noteToSelf], [utilityRef])
    SELECT [transferId], [transferTypeId], [acquirerCode], [transferIdAcquirer], [transferIdLedger], [transferIdIssuer], [transferIdMerchant], [transferDateTime],
        [localDateTime], [settlementDate], [channelId], [channelType], [ordererId], [merchantId], [merchantInvoice], [merchantPort], [merchantType], [cardId], [sourceAccount],
        [destinationAccount], [expireTime], [expireCount], [reversed], [retryTime], [retryCount], [ledgerTxState], [issuerTxState], [acquirerTxState], [merchantTxState],
        [issuerId], [ledgerId], [transferCurrency], [transferAmount], [acquirerFee], [issuerFee], [transferFee], [taxVAT], [taxWTH], [taxOther], [commission], [description],
        [comment], [noteToSelf], [utilityRef]
    FROM @transfer

    DECLARE
        @merchantPort varchar(50),
        @merchantMode varchar(20),
        @merchantSettlementDate datetime,
        @merchantSerialNumber bigint,
        @merchantSettings XML,
        @issuerPort varchar(50),
        @issuerMode varchar(20),
        @issuerSettlementDate datetime,
        @issuerSerialNumber bigint,
        @issuerSettings XML,
        @ledgerPort varchar(50),
        @ledgerMode varchar(20),
        @ledgerSerialNumber bigint,
        @userId bigint,
        @issuerId varchar(50),
        @ledgerId varchar(50),
        @merchantId varchar(50),
        @channelId bigint,
        @tranCount int,
        @transferDateTime datetime

    SET @userId = (SELECT [auth.actorId] FROM @meta)
          
    SELECT DISTINCT
        @issuerId = issuerId,
        @ledgerId = ledgerId,
        @merchantId = merchantId,
        @channelId = ISNULL (channelId, @userId),
        @tranCount = COUNT(*) OVER (PARTITION BY 1),
        @transferDateTime = ISNULL (transferDateTime, SYSDATETIME())
    FROM #transfer
    
    SELECT
        @merchantPort = port
    FROM [transfer].[partner]
    WHERE partnerId = @merchantId

    BEGIN TRANSACTION

        UPDATE [transfer].[partner]
        SET serialNumber = ISNULL(serialNumber, 0) + @tranCount
        WHERE partnerId IN (@ledgerId, @issuerId, @merchantId)

        INSERT INTO [transfer].[transfer] (transferDateTime, transferTypeId, acquirerCode, transferIdAcquirer, localDateTime, settlementDate, channelId, channelType, ordererId,
            merchantId, merchantInvoice, merchantPort, merchantType, cardId, sourceAccount, destinationAccount, expireTime, issuerId, ledgerId,
            transferCurrency, transferAmount, acquirerFee, issuerFee, transferFee, taxVAT, taxWTH, taxOther, commission, description, comment,
		    noteToSelf, utilityRef, reversed, ledgerTxState)
        OUTPUT INSERTED.transferId, INSERTED.sourceAccount, INSERTED.destinationAccount, INSERTED.transferAmount
        INTO #transferOutput (transferId, sourceAccount, destinationAccount, transferAmount)
        SELECT transferDateTime, transferTypeId, acquirerCode, transferIdAcquirer, ISNULL(localDateTime, REPLACE(REPLACE(REPLACE(CONVERT(varchar, transferDateTime, 120),'-',''),':',''),' ','')),
            settlementDate, @channelId, channelType,  @userId, merchantId, merchantInvoice, @merchantPort, merchantType, cardId, sourceAccount, destinationAccount,
            expireTime, issuerId, ledgerId, transferCurrency, transferAmount, acquirerFee, issuerFee, transferFee,
		    taxVAT, taxWTH, taxOther, commission, description, comment, noteToSelf, utilityRef, 0, 1
        FROM #transfer

    COMMIT TRANSACTION

    INSERT INTO [transfer].[event] (eventDateTime, transferId, [type], [state], source, [message])
    SELECT SYSDATETIME(), transferId, 'transfer.push', 'request', 'acquirer', 'Transfer created'
    FROM #transferOutput

    SELECT 'transferData' AS resultSetName
    SELECT transferId, sourceAccount, destinationAccount, transferAmount
    FROM #transferOutput

    IF OBJECT_ID('tempdb..#transfer') IS NOT NULL    
        DROP TABLE #transfer

    IF OBJECT_ID('tempdb..#transferOutput') IS NOT NULL    
        DROP TABLE #transferOutput

    EXEC core.auditCall @procid = @@PROCID, @params = @callParams
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    IF error_number() not in (2627)
        BEGIN
            EXEC [core].[error]
        END
    ELSE
    BEGIN TRY
        RAISERROR('transfer.idAlreadyExists', 16, 1);
    END TRY
    BEGIN CATCH
        EXEC [core].[error]
    END CATCH
END CATCH
