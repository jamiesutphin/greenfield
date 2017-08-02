
# coding: utf-8

# In[13]:


import matplotlib as mt
import json as js


# In[18]:


with open("/mnt/Downloads/consumer-complaints.json", "r")  as json_file:
    json_data = js.load(json_file)


# In[51]:


li = [1,2,3]
tu = (4,56, 67)
tu[0]


# In[65]:


json_data.keys()[0]


# In[41]:


j = json_data["meta"]["view"]["columns"]
len(j)


# In[67]:


for key , value in json_data.items():
    print (len(value))


# In[ ]:




