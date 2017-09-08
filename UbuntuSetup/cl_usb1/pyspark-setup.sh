

export JAVA_HOME=/home/jamie/Downloads/jdk1.8.0_144

export SPARK_HOME=/home/jamie/Downloads/spark-2.2.0-bin-hadoop2.7

export PATH=$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH

export PYSPARK_DRIVER_PYTHON=ipython

#to find local Spark build
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.4-src.zip:$PYTHONPATH

export PYSPARK_PYTHON=python3

# ready to start ipython
#ipython

# other options
# export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
#bin/pyspark 
# spark-submit

# or call jupyter --no-browser for a notebook in PyCharm
