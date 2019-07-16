select s.name, o.name, count(*)
from sys.indexes i
inner join sys.objects o on o.object_id = i.object_id
inner join sys.schemas s on s.schema_id = o.schema_id
where o.type_desc = 'user_table'
group by s.name, o.name 
order by 3 desc
