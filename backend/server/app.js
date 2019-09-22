const morgan = require('morgan');
const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');

const routes = require('./routes');
const errorHandlers = require('./handlers/errorHandlers');

const dev = process.env.NODE_ENV !== 'production';

// create our Express app
const app = express();

// Logger
if (dev) {
    app.use(morgan('dev'));
}

app.use(cookieParser());

// Takes the raw requests and turns them into usable properties on req.body
app.use(bodyParser.json());
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
);

app.use('/', routes);

// If that above routes didnt work, we 404 them and forward to error handler
app.use(errorHandlers.notFound);

module.exports = app;
