#!/usr/bin/env python
""" Testing connecting to DB2 utilizing pyodbc.

    AUTHOR: Tapio Vaattanen
    RELEASE HISTORY:
           2018/10/23 Tapio Vaattanen: Release 0.1 (initial release)

"""

import sys
import pyodbc
import pandas as pd


class DB2Utils(object):
    """
    This Class has basic set of DB2 Utilities.
    """
    def __init__(self, dsn, uid, pwd):
        """
        We need three parameters to connect while initializing:
            ODBC dsn name, User ID and Password.
        """
        self.dsn = dsn
        self.uid = uid
        self.pwd = pwd

    def db2_connect(self):
        """
        This method creates the database connection
        """
        try:
            cnxstr= 'DSN=' + self.dsn + '; UID=' + self.uid + '; PWD=' + self.pwd
            cnx = pyodbc.connect(cnxstr)
        except IOError as err:
            print("Error connecting to database: %s" % err)
            sys.exit(1)
        return cnx

    def write_to_df(self, connection, query):
        """
        Simple method to write query to Pandas data frame and resturn the
        data frame.
        """
        try:
            df = pd.read_sql(query, connection)
        except IOError as exc:
            sys.exit(exc)
        return df

    def write_to_stdout(self, connection, query):
        """"
        Write first column of the query to standard output.
        """
        crs = connection.cursor()
        crs.execute(query)
        while True:
            row = crs.fetchone()
            if not row:
                break
            print("Table name: %s" % row[0])

    def fetch_one(self, connection, query):
        crs = connection.cursor()
        crs.execute(query)
        row = crs.fetchone()
        return row
