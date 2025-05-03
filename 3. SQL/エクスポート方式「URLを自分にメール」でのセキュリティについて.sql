delete from [Binaries]
where [BinaryType] = 'ExportData'
and [CreatedTime] < dateadd(week,-1,getdate())