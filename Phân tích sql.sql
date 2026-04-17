create database Worlds_Oldest_Businesses
/* Project Phân tích Doanh nghiệp giàu nhất nước
*/
use Worlds_Oldest_Businesses
go
-- Xem xét dữ liệu của từng mảng và phân tích điểm chung
select * from businesses
/* Business chứa mã nước (có thể chuyển đổi sang tên được),
Năm được thành lập có thể sắp xếp để biết được doanh nghiệp lâu đời (Getdate và year)
Mỗi doanh nghiệp được phân loại theo hình thức kinh doanh cate có thể left join biết được loại
*/
select * from categories
-- Business và cate có điểm chung là cate_code 
select * from countries
-- Countries liên kết với business thông qua country code và vùng khu vực hoạt động 
select * from new_businesses 
-- business mới 
/* Đề Tài như sau 
>>> Khoảng thời gian thành lập của các công ty lâu đời nhất trên thế giới
+ Sử dụng công thức getdate và year, dateiff để tính toán khoảng cách của công ty lâu đời nhất
>>> Công ty lâu đời nhất thế giới và ngành công nghiệp mà nó thuộc về.
+ Left join và subquery nó lại với nhau giữa business và cate chỉ lập bảng mới chứa các ý cần dùng 
How many companies—and which ones—were founded before 1000 AD
>>> Các ngành công nghiệp phổ biến nhất mà các công ty lâu đời nhất thuộc về
Sử dụng sum và count tính toán các ngành phổ biến nhất của công ty lâu đời 
>> Các công ty lâu đời nhất theo châu lục
-- Business và countries có thể CTEs và sum châu lục
Các ngành công nghiệp phổ biến nhất của các công ty lâu đời nhất trên mỗi lục địa

*/
-- 1> Khoảng thời gian thành lập của các công ty lâu đời nhất trên thế giới
-- Kiểm tra có bao nhiêu công ty và có bị trùng lặp hay không 
select business, count(*) from businesses
group by business
having count(*) > 1
-- Kiểm tra cate có trùng không
select category, count(*) from categories
group by category
---
select 
	business,
	year_founded,
	Year(GETDATE()) as Hien_tai ,
	Year(GETDATE()) - year_founded   as age_busi,
	category_code,
	country_code 
from businesses
order by age_busi Desc
-- Công ty lâu đời nhất thế giới và ngành công nghiệp mà nó thuộc về.
select 
		business,
		year_founded,
		Year(GETDATE()) - year_founded   as age_busi,
		c.category_code,
		category
from businesses b
left join categories c
on b.category_code = c.category_code
order by age_busi desc
-- How many companies—and which ones—were founded before 1000 AD
select 'company' as company ,count(*) as total_comany from
(
select business,year_founded
from businesses
where year_founded <=1000)t
--- Nhành phổ biến nhất Count
select category,count(*)as total from 
(select 
		business,
		year_founded,
		Year(GETDATE()) - year_founded   as age_busi,
		c.category_code,
		category
from businesses b
left join categories c
on b.category_code = c.category_code)t
group by category
order by total DESC
-->> Các công ty lâu đời nhất theo châu lục
with CTE as
(select * ,
row_number() over (partition by continent order by Year(GETDATE()) - year_founded DESC ) as ranking
from (
 select business,
		year_founded,
		Year(GETDATE()) - year_founded  as age_busi,
		country,
		continent
from businesses b
	left join countries c 
	on b.country_code=c.country_code) as Sub
 )
select * from CTE
where ranking = 1
-- Các ngành công nghiệp phổ biến nhất của các công ty lâu đời nhất trên mỗi lục địa
select continent,category, count(*) as total from businesses b
			left join countries c
			on b.country_code=c.country_code
			left join categories ca
			on  b.category_code= ca.category_code
group by continent, category
order by continent, total DESC
