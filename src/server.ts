import App from './app'

import * as bodyParser from 'body-parser'
import loggerMiddleware from './middleware/logger'
import globalErrorHandler from './middleware/error.handler'

const port = +process.env.PORT! || 5000
const app = new App({
    port: port,
    middleWares: [
        bodyParser.json(),
        bodyParser.urlencoded({ extended: true }),
        loggerMiddleware,
        globalErrorHandler
    ]
})

app.listen()