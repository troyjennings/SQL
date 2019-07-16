select YEAR(create_date), count(*)
from dbo.financial_records
where create_date is not null
group by YEAR(create_date)
order by YEAR(create_date) DESC

select YEAR(modified_date_time), count(*)
from dbo.floorplans_audits
where modified_date_time is not null
group by YEAR(modified_date_time)
order by YEAR(modified_date_time) DESC

select YEAR(posted_date), count(*)
from dbo.financial_record_subledgers
where posted_date is not null
group by YEAR(posted_date)
order by YEAR(posted_date) DESC

select YEAR(create_date), count(*)
from dbo.financial_transactions
where create_date is not null
group by YEAR(create_date)
order by YEAR(create_date) DESC

select YEAR(create_date_time), count(*)
from dbo.title_action_histories
where create_date_time is not null
group by YEAR(create_date_time)
order by YEAR(create_date_time) DESC

select YEAR(modified_date_time), count(*)
from dbo.curtailment_amortization_histories
where modified_date_time is not null
group by YEAR(modified_date_time)
order by YEAR(modified_date_time) DESC

select YEAR(inspection_date_time), count(*)
from dbo.unit_inspections
where inspection_date_time is not null
group by YEAR(inspection_date_time)
order by YEAR(inspection_date_time) DESC

select YEAR(store_date_time), count(*)
from dbo.financial_record_caches
--where inspection_date_time is not null
group by YEAR(store_date_time)
order by YEAR(store_date_time) DESC

select YEAR(processed_date), count(*)
from dbo.floorplans
where processed_date is not null
group by YEAR(processed_date)
order by YEAR(processed_date) DESC

select YEAR(start_date), count(*)
from dbo.curtailments
where start_date < '1/1/2019'
group by YEAR(start_date)
order by YEAR(start_date) DESC

