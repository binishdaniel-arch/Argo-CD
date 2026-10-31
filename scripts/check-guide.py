from pathlib import Path
from html.parser import HTMLParser
import xml.etree.ElementTree as ET
class Check(HTMLParser):
 def __init__(self):super().__init__();self.buttons=0;self.ids=[];self.hrefs=[]
 def handle_starttag(self,t,a):
  a=dict(a)
  if t=='button':self.buttons+=1
  if 'id' in a:self.ids.append(a['id'])
  if t=='a':self.hrefs.append(a.get('href',''))
p=Check();p.feed(Path('index.html').read_text(encoding='utf-8'))
assert p.buttons>=30
assert len(p.ids)==len(set(p.ids))
for h in p.hrefs:
 if h.startswith('#'):assert h[1:] in p.ids
 elif not h.startswith('http'):assert Path(h).exists(),h
ET.parse('docs/architecture.svg')
print(f'HTML structure: {p.buttons} copy buttons; internal anchors and local links OK. SVG XML valid.')
