#!/usr/bin/env python
# coding: utf-8

import os
import argparse
from time import time

import pandas as pd
from sqlalchemy import create_engine


def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params. db
    url = params.url
    table_name = params.table_name

    csv_name = 'output.csv'

    # download the csv file of the yellow taxi dataset
    os.system(f'wget {url} -O {csv_name}')

    # connect to the Postgres database
    engine = create_engine(
        f'postgresql://{user}:{password}@{host}:{port}/{db}')

    # iterate through the dataset
    df_iter = pd.read_csv(csv_name, iterator=True,
                          chunksize=100000, low_memory=False)

    # get the data for this chunk (1st 100000 records)
    df = next(df_iter)

    # adjust the data types of pickup and dropoff times from text -> date
    df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
    df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    # create the table (data schema) with only the columns name to the connected database
    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    # insert the 1st chunk (100000 records) to the created table
    df.to_sql(name=table_name, con=engine, if_exists='append')

    while True:
        t_start = time()
        df = next(df_iter)
        df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
        df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)
        df.to_sql(name=table_name, con=engine, if_exists='append')

        t_end = time()
        print('inserted another chunck..., took %.3f seconds' % (t_end-t_start))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    parser.add_argument('--user', help='user name for postgres')
    parser.add_argument('--password', help='password for postgres')
    parser.add_argument('--host', help='hostname for postgres')
    parser.add_argument('--port', help='port number for postgres')
    parser.add_argument('--db', help='database name for postgres')
    parser.add_argument(
        '--table_name', help='name of the table where we will write results to')
    parser.add_argument('--url', help='url of the csv file')

    args = parser.parse_args()

    main(args)
