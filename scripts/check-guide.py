from pathlib import Path
from html.parser import HTMLParser
import re
import xml.etree.ElementTree as ET

class Check(HTMLParser):
    def __init__(self):
        super().__init__()
        self.buttons = 0
        self.ids = []
        self.links = []
        self.sources = []
        self.answers = 0
        self.in_code = False
        self.commands = []
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'button': self.buttons += 1
        if 'id' in attrs: self.ids.append(attrs['id'])
        if tag == 'a': self.links.append(attrs.get('href', ''))
        if tag == 'img': self.sources.append(attrs.get('src', ''))
        if tag == 'code': self.in_code = True
        if tag == 'details' and attrs.get('class') == 'interview':
            assert 'open' in attrs, 'Interview answers must be visible'
            self.answers += 1
    def handle_endtag(self, tag):
        if tag == 'code': self.in_code = False
    def handle_data(self, data):
        if self.in_code: self.commands.append(data)

for name, expected_answers in [('index.html', 15), ('lab2-argocd.html', 22), ('environments.html', 0)]:
    parser = Check()
    parser.feed(Path(name).read_text(encoding='utf-8'))
    assert len(parser.ids) == len(set(parser.ids)), name
    assert parser.answers == expected_answers, (name, parser.answers)
    assert not parser.buttons or "status" in parser.ids, "Copy feedback target is missing"
    for link in parser.links + parser.sources:
        if link.startswith('#'): assert link[1:] in parser.ids, (name, link)
        elif not link.startswith(('http:', 'https:')): assert Path(link).exists(), (name, link)
    for command in parser.commands:
        assert not re.search(r'powershell|Get-Content|Set-Content|Copy-Item|curl\.exe|\.ps1\b', command, re.I), (name, command)
    print(f'PASS {name}: {parser.buttons} copy buttons; links, images, visible answers and Bash-only command blocks')
for image in Path('docs').glob('*.svg'):
    ET.parse(image)
for script in Path('scripts').glob('*.sh'):
    data = script.read_bytes()
    assert b'\r' not in data, f'CRLF not allowed: {script}'
    assert not data.startswith(b'\xef\xbb\xbf'), f'BOM not allowed: {script}'
print('PASS SVG XML and Linux-compatible Bash line endings')
