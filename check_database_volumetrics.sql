SELECT TO_char(SNAP_TIME,'YYYY/MM'), round(SUM(BYTES_TOTAL/1024/1024/1024)) FROM 
OWNER_NAME.TABLESPACE_USAGE 
GROUP BY TO_char(SNAP_TIME,'YYYY/MM') ORDER BY TO_char(SNAP_TIME,'YYYY/MM') ASC;

select * FROM DBA_HIST_TABLESPACE_STAT;

select substr(rtime,4,7) data, tsname tablespace, max(tablespace_size) tamanho
from dba_hist_tablespace_stat t, dba_hist_tbspc_space_usage ts
where t.snap_id=ts.snap_id
and t.dbid=ts.dbid
and ts#=tablespace_id
group by substr(rtime,4,7), tsname
order by 1,2;


select 
concat(substr(rtime,0,3), substr(rtime,7,4)) data, 
sum(tablespace_size) total
from dba_hist_tbspc_space_usage
group by concat(substr(rtime,0,3), substr(rtime,7,4)) order by 1 ASC;


SELECT * FROM OWNER_NAME.TMON_SEGMENT_SIZE WHERE COLLECTED >= SYSDATE-3 AND COD_INSTANCE=1;

select owner, sum(size_mb) from OWNER_NAME.tmon_segment_size group by owner;

owner     = owner
collected = date
size_mb   = size

set linesize 200;
column owner format a30;
column size_mb format a40;

select collected, sum(size_mb) from OWNER_NAME.tmon_segment_size where owner = 'XXX' group by collected order by collected ASC;

select substr(collected,4,6), round(sum(size_mb/1024)) from OWNER_NAME.tmon_segment_size where owner = 'XXX' group by substr(collected,4,6) order by 1 ASC;

select substr(collected,4,6), sum(size_mb) from OWNER_NAME.tmon_segment_size where owner = 'XXX' and substr(collected,4,6) = 'AUG-13' group by substr(collected,4,6) order by 1 ASC;


--#Redo log files total
select 
round(sum(bytes/1024/1024/1024))
from v$log

--#Index size by owner and table
SELECT idx.index_name, SUM(bytes)
  FROM dba_segments seg,
       dba_indexes  idx
 WHERE idx.table_owner = <<owner of table>>
   AND idx.table_name  = <<name of table>>
   AND idx.owner       = seg.owner
   AND idx.index_name  = seg.segment_name
 GROUP BY idx.index_name


--------#############################################################################################################--------
--------#############################################################################################################--------
--------################################################ NEW QUERIES ################################################--------
--------#############################################################################################################--------
--------#############################################################################################################--------

--Database total size
select round(sum(bytes/1024/1024/1024)) gb from dba_segments;

--Monthly Data Growth
select substr(partition_name, 1, 7), round(sum(bytes/1024/1024/1024)) gb from dba_segments group by substr(partition_name, 1, 7);
select substr(partition_name, 1, 7), round(sum(bytes/1024/1024)) mb from dba_segments group by substr(partition_name, 1, 7);

--Monthly Data Growth by owner
select substr(partition_name, 1, 7), round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where OWNER = 'XXX' and segment_type not in ('INDEX PARTITION');
 

--Monthly Index Growth
select substr(partition_name, 1, 7), round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where OWNER = 'XXX' and segment_type in ('INDEX PARTITION')
group by substr(partition_name, 1, 7) order by 1;


--Index ofensor 07-2013 (particionado
select substr(partition_name, 1, 7), segment_name, bytes/1024/1024/1024 gb
from dba_segments 
where OWNER = 'XXX' and segment_type in ('INDEX PARTITION') and substr(partition_name, 1, 7) = 'PXXXXX'
order by 1, 2 asc;


--Monthly Index Growth (Partition)
select substr(p.partition_name, 1, 7), round(sum(s.bytes/1024/1024/1024)) gb
from dba_ind_partitions p, dba_segments s 
where 
s.partition_name = p.partition_name and
s.segment_type   = 'INDEX PARTITION' and
s.segment_name   = p.index_name and
p.index_owner    = s.owner and
p.index_owner = 'XXX'
group by substr(p.partition_name, 1, 7) order by 1;	

--Annual Data Growth
select substr(partition_name, 1, 5), sum(bytes/1024/1024/1024) gb
from dba_segments 
where OWNER = 'XXX' and segment_type not in ('INDEX PARTITION')
group by substr(partition_name, 1, 5) order by 1;

--Annual Index Growth
select substr(partition_name, 1, 5), sum(bytes/1024/1024/1024) gb
from dba_segments 
where OWNER = 'XXX' and segment_type in ('INDEX PARTITION')
group by substr(partition_name, 1, 5) order by 1;

--Monthly Data Compression
select substr(s.partition_name, 1, 7), p.compression, round(sum(s.bytes)/1024/1024/1024) gb
from dba_segments s, dba_tab_partitions p
where s.owner    = p.table_owner and 
s.segment_name   = p.table_name and 
s.partition_name = p.partition_name and
s.segment_type not in ('INDEX PARTITION') and
s.owner = 'XXX'
group by p.compression,substr(s.partition_name, 1, 7)
order by 1,2,3;

--Monthly Index Compression
select substr(p.partition_name, 1, 7), p.compression, round(sum(s.bytes/1024/1024/1024)) gb
from dba_ind_partitions p, dba_segments s 
where 
s.partition_name = p.partition_name and
s.segment_type   = 'INDEX PARTITION' and
s.segment_name   = p.index_name and
p.index_owner    = s.owner and
p.index_owner = 'XXX'
group by substr(p.partition_name, 1, 7), p.compression 
order by 1,2,3;

--Total data non-partitioned
select round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where OWNER = 'XXX' and segment_type not in ('INDEX PARTITION') and partition_name is null
order by 1;

--Total data partitioned
select round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where OWNER = 'XXX' and segment_type not in ('INDEX PARTITION') and partition_name is not null
order by 1;

--Total index non-partitioned
select round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where OWNER = 'XXX' and segment_type in ('INDEX') and partition_name is null
order by 1;

--Total index partitioned
select round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where OWNER = 'XXX' and segment_type in ('INDEX') and partition_name is not null
order by 1;

--Total
select distinct owner, round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
group by owner order by 1;

select distinct owner, round(sum(bytes/1024/1024)) mb
from dba_segments 
group by owner order by 1;

--Owners Data Size
select distinct owner, round(sum(bytes/1024/1024/1024)) gb
from dba_segments 
where segment_type not in ('INDEX PARTITION')
group by owner order by 1;

--Database growth last year
select to_char(creation_time, 'Mon-RRRR') month_year, round(sum(bytes/1024/1024/1024)) gb
from sys.v_$datafile
where creation_time > sysdate-365
group by to_char(creation_time, 'Mon-RRRR');

--------#############################################################################################################--------
--------#############################################################################################################--------
--------################################################ NEW QUERIES ################################################--------
--------#############################################################################################################--------
--------#############################################################################################################--------

create table my_dba_data_files
as
select sysdate dt, dba_data_files.* from dba_data_files;


create table my_dba_segments
as
select sysdate dt, dba_segments.* from dba_segments;


create procedure collect_sizes
as
begin
    insert into my_dba_data_files select trunc(sysdate), dba_data_files.* from dba_data_files;
    insert into my_dba_segments select trunc(sysdate), dba_segments.* from dba_segments;
end;