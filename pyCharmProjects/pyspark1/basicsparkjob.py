# coding: utf-8

"""
Setting up python job for spark-submit
requires environment variables to find the Spark libs

See setup.sh in Greenfield git
"""

from pyspark import SparkContext, SparkConf
appName = "Python1 app"
conf = SparkConf().setAppName(appName).setMaster("local")

sc = SparkContext(conf=conf)

f_rdd = sc.textFile("/etc/passwd")
f_rdd.take(5)

f_rdd.saveAsTextFile("test.out")

sc.stop()