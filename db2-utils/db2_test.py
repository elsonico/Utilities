pwd = base64.b64decode("TWFyaWEjMTJTYW56")#!/usr/bin/env python
""" Testing connecting to DB2  utilizing pyodbc.

    AUTHOR: Tapio Vaattanen
    RELEASE HISTORY:
           2018/10/08 Tapio Vaattanen: Release 0.1 (initial release)

"""

import sys
import pyodbc
import pandas as pd
import base64
from db2_utils import DB2Utils


class DB2Test(object):
    """
    This Class is meant for simple testing DB2Utils.
    """
    def __init__(self, output_file):
        self.output_file = output_file

    def main(self):
        dsn = 'sample'
        # Obfuscating the credentials with totally unsafe way.
        uid = base64.b64decode("ZGIyaW5zdDE=")
        pwd = base64.b64decode("'cGFzc3dvcmQ=")
        db2_utils = DB2Utils(dsn, uid, pwd)
        db2_connection = db2_utils.db2_connect()
        query = "select tabname from syscat.tables where tabschema = 'db2inst1'"
        df = db2_utils.write_to_df(db2_connection, query)
        db2_utils.write_to_stdout(db2_connection, query)
        db2_connection.close()
        try:
            sql_file = open(self.output_file , "w")
        except IOError as err:
            print("Error writing to  output file: %s" % err)
            sys.exit(1)
        for index, row in df.iterrows():
            sql_file.write("Table name: " + df.iloc[index, 0] + "\n")


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: %s [output_file]" % (sys.argv[0]))
        sys.exit(1)
    output_file = sys.argv[1]
    db2_test = DB2Test(output_file)
    db2_test.main()
