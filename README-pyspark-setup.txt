

export JAVA_HOME= <path to java>
export PATH= <add Java home>

export SPARK_HOME=<your spark home path>
export PATH=$SPARK_HOME/bin:$PATH



Options
1. calling command line pyspark
cd $SPARKHOME
bin/pyspark 

2. calling jupyter notebook
export PYSPARK_DRIVER_PYTHON=jupyter
export PYSPARK_DRIVER_PYTHON_OPTS='notebook'
bin/pyspark 

