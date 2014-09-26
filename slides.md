# Messing with government data using Python

.fx: title-slide middle notitle

# Messing with government data using Python

<br/>

<p class="title-p">
    PyCon India 2014
    <br/>
    <span class="small">September 27-28, 2014</span>
</p>

<br/>
<br/>
<br/>
<br/>

<p class="title-p">
    <a class="author" href="http://openlibrary.org/anand">Anand Chitipothu</a>
    <br/>
    <a src="https://twitter.com/anandology">@anandology</a>
</p>

---

# During the General Elections 2014...

I volunteered to provide technical assitance to an election campaign in Bangalore (and also in Andhra Pradesh).

---

# And I ended up building...

* A campaign management system
* volunteer signup system
* webapp to find voter details by voterid
* script to format voter lists of a polling center as PDF in compact form
* and other small tittle tools

![GitHub Activity](images/github-activity.png)

---

# Glossary

* Paliamentary Constituency (*PC25 - Bangalore North*)
* Assembly Constituency (*AC158 - Hebbal*)
* Ward (*W046 - Jayachamarajendra Nagar*)
* Polling Center
	* Typically  a school/govt building containing one or more polling booths
	* E.g. *PX065 - Adarsha Vidya Mandira, R T Nagara*
* Polling Booth
	* E.g. *PB0203 - Adarsha Vidya Mandira, Room No-1*
	* Typically have about 1000 voters
* VoterID
	* unique (supposed to be) identifier for a voter	
* CEO - Chief Electoral Officer
	* <http://www.ceokarnataka.kar.nic.in>
---

# The Challenges

---

## The Campaign Management System

.fx: ol-bg center notitle bottom-title

<img src="images/cms-1.png" style="width: 100%;"/>

---

## The Campaign Management System

.fx: ol-bg center notitle bottom-title

<img src="images/cms-2.png" style="width: 100%;"/>

---

## Parliamentaty & Assembly Constituencies

.fx: notitle

<img src="images/wikipedia-lc-mapping.png" style="width: 100%;"/>

<div class="banner">
    <h3><a href="https://en.wikipedia.org/wiki/List_of_constituencies_of_the_Lok_Sabha#Karnataka_.2828.29">https://en.wikipedia.org/wiki/List_of_constituencies_of_the_Lok_Sabha</a></h3>
</div>

---

## Finding Polling Booths

.fx: notitle

<img src="images/AC158-booths.png" style="width: 100%;"/>

<div class="banner">
    <h3><a href="http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/Part_List.aspx?ACNO=158">http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/Part_List.aspx?ACNO=158</a></h3>
</div>

---

## Finding Ward

.fx: notitle

<img src="images/AC1580203-page1.png" style="width: 100%;"/>

<div class="banner">
    <h4><a href="http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/PCROLL_2014/English/WOIMG/AC158/AC1580203.pdf">http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/PCROLL_2014/English/WOIMG/AC158/AC1580203.pdf</a></h4>
</div>

---

## Volunteer Sign Up System

.fx: ol-bg center notitle bottom-title

<img src="images/vol-signup-1.png" style="width: 100%;"/>

---
## Volunteer Sign Up System

.fx: ol-bg center notitle bottom-title

<img src="images/vol-signup-2.png" style="width: 100%;"/>

---
## Volunteer Sign Up System

.fx: ol-bg center notitle bottom-title

<img src="images/add-volunteer.png" style="width: 100%;"/>

---

## Find Your Polling Booth

.fx: ol-bg center notitle bottom-title

<img src="images/voter-search.png" style="width: 100%;"/>

---

## Voter Data

.fx: notitle

<img src="images/AC1580203-page3.png" style="width: 100%;"/>

<div class="banner">
    <h4><a href="http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/PCROLL_2014/English/WOIMG/AC158/AC1580203.pdf">http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/PCROLL_2014/English/WOIMG/AC158/AC1580203.pdf</a></h4>
</div>
---

## Compact Voter List

.fx: ol-bg center notitle bottom-title

<img src="images/compact-voterlist.png" style="width: 100%;"/>

---
## Important Polling Centers 

.fx: ol-bg center notitle bottom-title

<img src="images/AC142-px-sorted.png" style="width: 100%;"/>

---

# The Fun Part

---

# Parsing HTML pages

* Beautiful Soup is your friend
* Always save intermediate results
* ASP.net is the worth thing ever happened to web

---

## BeautifulSoup

<pre>
<span class="highlight">from bs4 import BeautifulSoup</span>
import urllib2

def parse(html):
	<span class="highlight">soup = BeautifulSoup(html)</span>
	
	# find all tds in a table
	<span class="highlight">rows = soup.select("#ctl00_ContentPlaceHolder1_GridView1 tr")</span>

	# extract text for all rows except the header row
	for tr in rows[1:]:
		<span class="highlight">tds = tr.find_all("td")</span>
		yield [<span class="highlight">td.get_text()</span> for td in tr.find_all("td")]

URL = ("http://ceokarnataka.kar.nic.in/ElectionFinalroll2014/" + 
	   "Part_List.aspx?ACNO=158")

html = urllib2.urlopen(URL).read()
data = parse(html)
</pre>

---

## Save Intermediate Results

<pre>
<span class="highlight">@cache.disk_memoize("cache/wp.html")</span>
def get_wp_page():
    return urllib2.urlopen(WP_URL).read()

<span class="highlight">@cache.disk_memoize("cache/table_{0}.json")</span>
def get_table_for_state(state):
	...

<span class="highlight">@cache.disk_memoize("cache/{state_name}_pc.tsv")</span>
def get_pc_list(state_name):
    return [['PC{0:02d}'.format(int(row[0])), row[1].strip()] 
    		for row in get_table_for_state(state_name)]
</pre>
--- 

## The Hell of ASP.net

.fx: ol-bg center

<img src="images/asp-hell.png" style="width: 100%;"/>

---
## Escaping the Hell of ASP.net

<pre>
@cache.disk_memoize("cache/MP/districts.json")
def get_districts(self):
    return <span class="highlight">self.browser.get_select_options("ddlDistrict")</span>

@cache.disk_memoize("cache/MP/AC{ac:03d}_booths.tsv")
def get_booths_of_ac(self, dist, ac):
    <span class="highlight">self.browser.select_option('ddlDistrict', dist)</span>
    <span class="highlight">self.browser.select_option('ddlAssembly', ac)</span>
    soup = self.browser.get_soup()
    ...
</pre>
---
# Parsing PDFs

.fx: ol-bg center

<img src="images/xkcd-re.png" style="width: 90%;"/>

<div class="banner">
Image derived from <a href="http://xkcd.com/208/">http://xkcd.com/208/</a><br/>
<div style="font-size: 0.8em;">Creative Commons Attribution-NonCommercial 2.5 License.</div>
</div>

---

## PDF to Text

* pdftotext -layout a.pdf a.txt

---

# Formatting Voter Lists

* ReportLab works fine. 
* Beware of performance issues.

---

# Post Elections

I continued to improve the system to make it generic and extendable.

![GitHub Activity](images/github-activity2.png)
