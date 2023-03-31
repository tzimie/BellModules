from bell import *
from MYSQLquery import *
from tabulate import tabulate
import numpy as np
import pandas as pd
import plotly.express as px
# also requires kaleido

usr, grp, name, tags, tagval = bellparams()

conn = tagval['Conn']

q = """SELECT
  `performance_schema`.`file_summary_by_instance`.`FILE_NAME` AS `file`,
  `performance_schema`.`file_summary_by_instance`.`COUNT_READ` AS `count_read`,
  `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_READ` AS `total_read`,
  ifnull(`performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_READ` / nullif(`performance_schema`.`file_summary_by_instance`.`COUNT_READ`,0),0) AS `avg_read`,
  `performance_schema`.`file_summary_by_instance`.`COUNT_WRITE` AS `count_write`,
  `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_WRITE` AS `total_written`,
  ifnull(`performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_WRITE` / nullif(`performance_schema`.`file_summary_by_instance`.`COUNT_WRITE`,0),0.00) AS `avg_write`,
  `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_READ` + `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_WRITE` AS `total`,
  ifnull(round(100 - `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_READ` / nullif(`performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_READ` + `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_WRITE`,0) * 100,2),0.00) AS `write_pct`
FROM `performance_schema`.`file_summary_by_instance` order by `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_READ` + `performance_schema`.`file_summary_by_instance`.`SUM_NUMBER_OF_BYTES_WRITE` desc"""

data = []
d = MYSQLquery(conn, q)
for r in d:
  if r[1]>0 or r[4]>0:
    data.append([ r[0], r[1], r[4] ])

df = pd.DataFrame(np.array(data), columns=['file', 'reads', 'writes'])

fig = px.treemap(df, path=['file'], values='reads')
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
fig.write_image("ioreads.jpg", width=1080, height=720)

fig = px.treemap(df, path=['file'], values='writes')
fig.update_layout(margin = dict(t=50, l=25, r=25, b=25))
fig.write_image("iowrites.jpg", width=1080, height=720)


print (f"""<html>
<h1>InnoDB IO reads by file</h1>
<body style="background: black;">
<img src="ioreads.jpg">
</body>
<h1>InnoDB IO writes by file</h1>
<body style="background: black;">
<img src="iowrites.jpg">
</body>
</html>""")
