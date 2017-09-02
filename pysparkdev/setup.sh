# source to start pyspark


export JAVA_HOME=~/Downloads/jdk1.8.0_131
export PATH=$JAVA_HOME/bin:$JAVA_HOME/lib:$PATH:


export SPARK_HOME=./spark-2.2.0-bin-hadoop2.7
export PATH=$SPARK_HOME/bin:$PATH



# Options
# 1. calling command line pyspark
# cd $SPARKHOME
# bin/pyspark 

# 2. calling jupyter notebook
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'

#bin/pyspark

