import json
import numpy as np
import pandas as pd
import psycopg2
from io import StringIO

def db_engine():
    config = json.load(open("config.json"))
    host = config["connection"]["host"]
    port = config["connection"]["port"]
    user = config["connection"]["user"]
    password = config["connection"]["password"]
    db = config["connection"]["db"]

    return "user='{}' password='{}' host='{}' port='{}' dbname='{}'".format(
        user, password, host, port, db
    )

def sql_to_df(sql_query):
    try:
        conn = psycopg2.connect(db_engine())
        cur = conn.cursor()
        cur.execute(sql_query)
        df = pd.DataFrame(cur.fetchall(), columns=[elt[0] for elt in cur.description])
        cur.close()
        return df
    except Exception as e:
        print("Problems:", str(e))
    
    return None


def get_data():
    config = json.load(open("config.json"))
    table = config["automl"]["tabledata"]
    features = config["automl"]["featuresdata"]
    get_data_sql = f"select {','.join(features)} from {table}"
    df = sql_to_df(get_data_sql)
    if df is None:
        return None
    #return df[features], df[target]
    return df[features]

def get_activity():
    config = json.load(open("config.json"))
    table = config["automl"]["tableact"]
    features = config["automl"]["featuresact"]
    get_data_sql = f"select {','.join(features)} from {table}"
    df = sql_to_df(get_data_sql)
    if df is None:
        return None
    #return df[features], df[target]
    return df[features]
    
