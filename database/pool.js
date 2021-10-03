const mysql = require('mysql');
const config = require("./config");
const dotenv = require("dotenv");
dotenv.config();

const env = process.env.NODE_ENV ? process.env.NODE_ENV.trim() : 'development';

const { username, password, database, host } = config[env];

const pool = mysql.createPool({
  host,
  user: username,
  password,
  database,
  timezone: '+00:00',
  dateStrings: ['DATE', 'DATETIME'],
  typeCast: (field, next) => { // Para hacer el parseo a JSON automáticamente
    if (field.type.includes('BLOB')) { // && field.length == 4294967295
      let value;
      try {
        value = field.string();
        return JSON.parse(value);
      } catch (e) {
        return value;
      }
    }
    return next();
  }
});

const testConnectionDB = () => {
  return new Promise((resolve, reject) => {
    pool.query('SELECT 1 + 1 AS solution', function (err, results) {
      if (err) {
        return reject(err);
      }
      return resolve(results[0].solution);
    });
  })
}

const queryDB = (sql, args) => {
  return new Promise((resolve, reject) => {
    pool.getConnection(function (err, connection) {
      if (err) {
        return reject(err)
      }
      // Use the connection
      connection.query(sql, args, function (err, results, fields) {
        // When done with the connection, release it.
        connection.release();
        // Handle error after the release.
        if (err) {
          return reject(err);
        }
        return resolve(results, fields);
      });
    });
  })
}

const endPool = () => {
  return new Promise((resolve, reject) => {
    pool.end(function (err) {
      if (err) {
        return reject(err);
      }
      return resolve();
    });
  });
}

module.exports = {
  pool,
  testConnectionDB,
  endPool,
  queryDB
};