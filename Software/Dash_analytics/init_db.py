import numpy as np
import pandas as pd
import psycopg2
from io import StringIO

from db_postgres import db_engine 


df = pd.read_csv("sensordata.csv")

try:
    conn = psycopg2.connect(db_engine())
    cur = conn.cursor()
  
    print("Insert data into sensor table ...")
    buffer = StringIO()
    df.to_csv(buffer, index_label="id", header=False)
    buffer.seek(0)
    cur.copy_from(buffer, "sensor", sep=",")
    conn.commit()
    print("Insert finished.")

    cur.close()
except Exception as e:
    print("Problems:", str(e))


dff = pd.read_csv("sensordataactivity.csv")

try:
    conn = psycopg2.connect(db_engine())
    cur = conn.cursor()

    print("Insert data into activity table ...")
    buffer = StringIO()
    dff.to_csv(buffer, index_label="id", header=False)
    buffer.seek(0)
    cur.copy_from(buffer, "activity", sep=",")
    conn.commit()
    print("Insert finished.")

    cur.close()
except Exception as e:
    print("Problems:", str(e))