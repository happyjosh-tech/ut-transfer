var joi = require('joi');

module.exports = {
    description: 'Pushes created transfer into rabbitMQ',
    params: joi.object().keys({
        transferId: joi.number(),
        message: joi.string(),
        userAvailableAccounts: joi.array().items(joi.string())
    }),
    result: joi.any()
};
