
const BANK_ACQUIRER_CODE = 'bankAcquirerCodeDebit'
const BANK_ACQUIRER_CODE_PREFIX = 'BAC' 
const LEDGER_ID = 'ledger'
const ISSUER_ID = 'ledger'

const shortid = require('shortid')
const moment = require('moment')

class TransactionDebitSuspense {
    constructor(obj) {
        this.bus = obj.bus;
    }

    getTransferId(operationName) {
        return this.bus.importMethod('db/rule.operation.lookup')({ operation: operationName })
            .then(result => {
                if (!result.operation) {
                    throw Error('Not operation id by name: ' + operationName)
                } 
                
                return result.operation.transferTypeId;
            });
    }


    prepareAllocationParams(msg) {
        let floatAccountLimits = []
        for(let floatNumber in msg.floatAccountNumbers) {
            floatAccountLimits.push(
                {
                    key: floatNumber,
                    value: msg.floatAccountNumbers[ floatNumber ].limit
                }
            )
        }
        return {
            suspenseAccountNumber: msg.suspendAccountNumber,
	        depositAmount: msg.depositAmount,
            floatAccountNumberLimits: floatAccountLimits
	    }
    }

    generateTransferIdAcquirer() {
        return BANK_ACQUIRER_CODE_PREFIX + shortid.generate()
    }
    
    async prepareTrxTTData(msg, $meta) {
        const transferTypeId = await this.getTransferId('cashInToBankAccountAtAgent')
        const initValues = {
            transferTypeId,  //cashInToBankAccountAtAgent  
	        acquirerCode: BANK_ACQUIRER_CODE,
	        transferIdAcquirer: this.generateTransferIdAcquirer(),
            channelId: $meta.auth.actorId,
            channelType: msg.channelType || 'web',
            expireTime: moment(new Date()).add(1, 'h'),
            issuerId: ISSUER_ID,
	        ledgerId : LEDGER_ID,
            transferAmount: msg.depositAmount,
            transferDateTime: new Date()
	    }
        return TransactionDebitSuspense.initTrxField(initValues, msg)
    }

    prepareBulkTrxParams(msg, depositAllocations, trxParams) {
        let trxData = [
            Object.assign(
                {}, 
                trxParams, 
                {
                    sourceAccount: null,
                    destinationAccount: msg.suspendAccountNumber,
                    transferCurrency: msg.depositCurrency,
                    transferAmount: msg.depositAmount,
                }
            )
        ]
        const transferIdAcquirer = this.generateTransferIdAcquirer()
        depositAllocations.forEach(floatAccountData => {
            //trx - allocate deposit to float account
            const trxFloat = Object.assign(
                {}, 
                trxParams, 
                {
                    sourceAccount: msg.suspendAccountNumber,
                    transferCurrency: msg.depositCurrency,
                    destinationAccount: floatAccountData.destinationAccountNumber,
                    transferAmount: floatAccountData.transferAmount,
                    transferIdAcquirer: transferIdAcquirer
                }
            )
            trxData.push(trxFloat)
        })
        return trxData
    }

    prepareBalanceParams(msg, depositAllocations) {
        let transferBalanceUpdate = [
            {
            debit: null,
            credit: msg.suspendAccountNumber,
            amount: msg.depositAmount
            }
        ]

        depositAllocations.allocations.forEach(floatAccountData => {
            transferBalanceUpdate.push(
                {
                    debit: floatAccountData.sourceAccountNumber,
                    credit: floatAccountData.destinationAccountNumber,
                    amount: floatAccountData.transferAmount
                }
            )
        })

        return transferBalanceUpdate
    }

    static initTrxField(initValues, inputData) {
        let fieldValue = {}
        TransactionDebitSuspense.trxFields.forEach( item => {
            fieldValue[item] = inputData[item] || initValues[item] || null
        })
        return fieldValue
    }
}

TransactionDebitSuspense.trxFields = [
    'transferId',
    'transferTypeId',  
    'acquirerCode',
    'transferIdAcquirer',
    'transferIdLedger',
    'transferIdIssuer',
    'transferIdMerchant',
    'transferDateTime',
    'localDateTime',
    'settlementDate',
    'channelId',
    'channelType',
    'ordererId',
    'merchantId',
    'merchantInvoice',
    'merchantPort',
    'merchantType',
    'cardId',
    'sourceAccount',
    'destinationAccount',
    'expireTime',
    'expireCount',
    'reversed',
    'retryTime',
    'retryCount',
    'ledgerTxState',
    'issuerTxState',
    'acquirerTxState',
    'merchantTxState',
    'issuerId',
    'ledgerId',
    'transferCurrency',
    'transferAmount',
    'acquirerFee',
    'issuerFee',
    'transferFee',
    'taxVAT',
    'taxWTH',
    'taxOther',
    'commission',
    'description',
    'comment',
    'noteToSelf',
    'utilityRef'
]


module.exports = TransactionDebitSuspense;
