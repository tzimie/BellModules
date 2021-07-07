param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

# hash for tags
$tagval = @{}
foreach ($g in ($tags).Split("~")) {
  $tagval[$g.Split('=')[0]] = $g.Split('=')[1]
}

function printXML([xml]$u)  
{
  # generate text with idents
  $StringWriter = New-Object System.IO.StringWriter;
  $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter;
  $XmlWriter.Formatting = "indented";
  $u.WriteTo($XmlWriter);
  $XmlWriter.Flush();
  $StringWriter.Flush();

  $idented = $StringWriter.ToString()
  $idented = $idented -Replace ' ','{sp}'
  $idented = $idented -Replace "`n",'{br}'
  $html = [Net.WebUtility]::HtmlEncode($idented) 

  # finalize spaces and breaks
  $html = $html -Replace '{sp}','&nbsp;'
  $html = $html -Replace '{br}','<br>'

  # hightlighting
  $html = $html -Replace '&lt;([\w|\-]*)&gt;', '<font color="blue">&lt;$1&gt;<font color="black">' #  <tags>
  $html = $html -Replace '&lt;([\w|\-]*)&nbsp;', '<font color="blue">&lt;$1&nbsp;<font color="black">' #  <tag (space)
  $html = $html -Replace '&lt;([\w|\-]*)&nbsp;', '<font color="blue">&lt;$1&nbsp;<font color="black">' #  <tag (space)
  $html = $html -Replace '&lt;/([\w|\-]*)&gt;', '<font color="blue">&lt;/$1&gt;<font color="black">' #  </tags>
  $html = $html -Replace '&nbsp;/&gt;', '<font color="blue">&nbsp;/&gt;<font color="black">' # (space)/>
  return $html
}

[xml]$xml = Get-Content $tagval.dir
$h = printXML $xml
$h
