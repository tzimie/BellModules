from bell import *
from MSSQLquery import *
from PIL import Image, ImageDraw
from PIL import ImagePath, ImageFont
import colorsys
from collections import defaultdict

usr, grp, name, tags, tagval = bellparams()
conn = tagval['Conn']
filt = tagval['filter']
if filt>'': filt =  f" and ({filt})"

q = f"""select name, step_id, run_status, runday, runtime, duration
from (
select name, step_id, run_status, 
  datediff(dd, dateadd(ss, runtime, rundate), getdate()) as runday,
  runtime, duration
from (
select name, step_id, run_status, 
  convert(datetime,rundate) as rundate,
  runtimeh*3600+runtimem*60+runtimes as runtime,
  durh*3600+durm*60+durs as duration
from (
select J.name,
  step_id, run_time,
  run_time/10000 as runtimeh, run_time/100%100 as runtimem, run_time%100 as runtimes, 
  run_duration/10000 as durh, run_duration/100%100 as durm, run_duration%100 as durs,
  convert(date,convert(varchar,run_date)) as rundate,
  convert(varchar,run_duration) as run_duration,
  run_status
  from msdb..sysjobhistory H
  inner join msdb..sysjobs J on J.job_id=H.job_id
  where step_id<>0 {filt}
) Q ) Q1) Q2
  where runday<8
  order by name,runday desc,runtime,step_id
"""

def col(item, of):
  (r, g, b) = colorsys.hsv_to_rgb(0.25+item/of/2, 1.0, 1.0)
  col = '#%02X' % int(r*255) + '%02X' % int(g*255) + '%02X' % int(b*255)
  return col

# delute a color by day, morew day ago, less visible
def colday(col, day):
  if day == 0: return col # no change for day 0
  r = int(col[1:3] ,16)
  g = int(col[3:5] ,16)
  b = int(col[5:7] ,16)
  r = 255 - ((255 - r) // (day+1))
  g = 255 - ((255 - g) // (day+1))
  b = 255 - ((255 - b) // (day+1))
  col = '#%02X' % r + '%02X' % g + '%02X' % b
  return col

# box with color inside
def drawbox(day, x1, y1, width, height, col, isfailed):
  y1 -= day*3
  if x1+width>maxx:
    width = maxx-x1 # over midnight
  imgd.polygon([(x1,y1),(x1,y1+height),(x1+width,y1+height),(x1+width,y1)], fill=colday(col,day), outline=colday("#000000",day), width=1)
  if isfailed:
    y1 += 1
    height = 4
    if width>3:
      x1 += 1
      width -= 1
    imgd.polygon([(x1,y1),(x1,y1+height),(x1+width,y1+height),(x1+width,y1)], fill=colday("#FF0000",day), outline=None, width=1)

# convert absolute seconds to x
def sec2x(seconds):
  return 15+int((size[0]-30)*seconds/86400)

# convert duration seconds to x width
def sec2width(seconds):
  return int((size[0]-30)*seconds/86400)

# rank to y
def rank2y(rank):
  return 25+rank*(jobheight+20)

# draw job step boxes
def drawjob(day, x, y, lenlist, faillist):
  if y>size[1]-30: return
  xpos = x
  i = 0
  for st in lenlist:
    while True:
      drawbox(day, sec2x(xpos), y, sec2width(st), jobheight, col(i, len(lenlist)), faillist[i])
      if xpos+st>86400: # over midnight
        st = xpos+st-86400
        xpos = 0
        day -= 1
      else:
        break
    xpos += st
    i += 1

# job name to rank
def job2rank(jobname):
  r = 0
  for k in sortedjobs:
    if k[0] == jobname:
      return r
    r += 1  

# draw job by rank id and translate timings (in minutes from the beginning of the day)
def drawjobrel(day, rank, start, durationlist, faillist):
  drawjob(day, start, rank2y(rank), durationlist, faillist)

size = 1080, 720
maxx = size[0] - 15
jobheight = 15

d = MSSQLquery(conn, q)

# PASS 1, ranking 
jobtotals = defaultdict(int) 
for r in d:
  jobname = r[0]
  duration = r[5]
  jobtotals[jobname] -= duration # to sort in reversed order

sortedjobs = sorted(jobtotals.items(), key=lambda x:x[1])

# PASS 2, drawing
img = Image.new("RGB", size, "white") 
imgd = ImageDraw.Draw(img)  
fnt = ImageFont.truetype(sys.path[0]+"/arial.ttf")

# hour grid
for h in range(0,25,3):
  x = sec2x(h*3600)
  imgd.line( [ (x,15), (x, size[1]-15)], fill="#8080FF")  
  imgd.text((x-5, size[1]-13), str(h)+'h', font=fnt, fill=(0, 0, 0, 128))

durations = []
statuses = []
old_job = ''
old_step = 0
old_start = 0
old_runday = 0
for r in d:
  jobname = r[0]
  stepid = r[1]
  runstatus = r[2]
  runday = r[3]
  runtime = r[4]
  duration = r[5]
  if (old_job == jobname) and (old_step+1 == stepid): # continue
    durations.append(duration)
    statuses.append(1-runstatus)
    old_step = stepid
  else: # new job, draw previous one
    if old_job>'': # not the very first one
      drawjobrel(old_runday,job2rank(old_job),old_start,durations,statuses)
    old_runday = runday
    old_job = jobname
    old_step = 1
    durations = [duration]
    statuses = [1-runstatus]
    old_start = runtime
if old_job>'': # not the very first one
  drawjobrel(runday,job2rank(jobname),runtime,durations,statuses)

# draw text
r = 0
for k in sortedjobs:
  y = rank2y(r)-15
  if y>size[1]-30: break
  imgd.text((20, y), k[0], font=fnt, fill=(0, 0, 0, 128))
  r += 1  

img.save("jobs.png")
 
print (f"""<html>
<h1>Jobs step duration by day and time, red indicating failures
</h1>
<body style="background: black;">
<img src="jobs.png">
</body>
</html>""")