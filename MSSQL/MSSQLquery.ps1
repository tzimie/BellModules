function MSSQLquery([string] $connstr, [string]$sql)
  {
  $sqlConn = New-Object System.Data.SqlClient.SqlConnection
  $sqlConn.ConnectionString = $connstr
  $sqlConn.Open()
  $sqlcmd = New-Object System.Data.SqlClient.SqlCommand
  $sqlcmd.Connection = $sqlConn
  $query = $sql
  $sqlcmd.CommandText = $query
  $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
  $data = New-Object System.Data.DataSet
  $adp.Fill($data) | Out-Null
  return $data.Tables[0]
}

function MSSQLchart([string] $connstr, [string]$sql)
  {
  $sqlConn = New-Object System.Data.SqlClient.SqlConnection
  $sqlConn.ConnectionString = $connstr
  $sqlConn.Open()
  $sqlcmd = New-Object System.Data.SqlClient.SqlCommand
  $sqlcmd.Connection = $sqlConn
  $query = $sql
  $sqlcmd.CommandText = $query
  $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
  $data = New-Object System.Data.DataSet
  $adp.Fill($data) | Out-Null

  $cols = ''
  $len = 0
  foreach ($col in $data.Tables[0].Columns) {
    if ($cols -ne '') { $cols = $cols + ',' }
    $cols = $cols + $col
    $len++
  }
  Write-Host $cols
  foreach ($row in $data.Tables[0]) {
    $cols = ''
    for ($n=0; $n -lt $len; $n++) {
      if ($cols -ne '') { $cols = $cols + ',' }
      if ($n -eq 0) { $cols = $cols + $row[$n].ToString('yyy-MM-ddThh:mm:ss') }
      else { $cols = $cols + $row[$n] }
    }
  Write-Host $cols
  }
}

function MSSQLscalar([string] $connstr, [string]$sql)
  {
  $sqlConn = New-Object System.Data.SqlClient.SqlConnection
  $sqlConn.ConnectionString = $connstr
  $sqlConn.Open()
  $sqlcmd = New-Object System.Data.SqlClient.SqlCommand
  $sqlcmd.Connection = $sqlConn
  $query = $sql
  $sqlcmd.CommandText = $query
  $adp = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcmd
  $data = New-Object System.Data.DataSet
  $adp.Fill($data) | Out-Null
  $firstrow = $data.Tables[0][0]
  return [int]$firstrow.cnt
}


# for $tags create hash tables
function parse([string]$tags) 
  {
  $global:tagval = @{}
  foreach ($g in ($tags).Split("~")) {
    $k = $g.Split('=')[0]
    $v = $g.Substring(1+$k.Length)
    $global:tagval[$k] = $v
    }
}
  
