#limpieza de datos 
use clean;

SELECT 
    *
FROM
    Limpieza
LIMIT 10;

DELIMITER //

CREATE PROCEDURE limp()
BEGIN 
    SELECT * FROM Limpieza;
END //
DELIMITER ;
CALL limp();
ALTER TABLE Limpieza change column `ï»¿Id?empleado` Id_emp varchar (20) null;
ALTER TABLE Limpieza change column `gÃ©nero` Gender varchar (20) null;
ALTER TABLE Limpieza change column `Apellido` Last_name varchar (20) null;
ALTER TABLE Limpieza change column `Start_date` start_date varchar (50) null;
select id_emp, count(*) as cantidad_duplicados
from Limpieza
group by Id_emp
having count(*) > 1;

SELECT COUNT(*) AS cantidad_duplicados
from(
select id_emp, count(*) as cantidad_duplicados
from Limpieza
group by Id_emp
having count(*) > 1
) as subquery;

rename table Limpieza to conduplicados;

CREATE TEMPORARY TABLE Temp_Limpieza AS
SELECT DISTINCT * FROM conduplicados;
select count(*) as original from conduplicados;

select count(*) as original from Temp_Limpieza;

create table LIMPIEZA AS SELECT * FROM Temp_limpieza;

call LIMP();
#comando que permite hacer cambios

 SET  sql_safe_updates = 0;
 
DESCRIBE LIMPIEZA;
#ensayo de consulta 
select name from Limpieza
where  length (name) - length(trim(name))>0;

select name, trim(name) as name 
from limpieza 
where  length(name) - length(trim(name)) > 0;

#modificacion

update Limpieza set name  = trim(name)
where  length (name) - length(trim(name))>0;

SHOW COLUMNS FROM clean.Limpieza;

#ensayo de consulta 
select Last_name from Limpieza
where  length (Last_name) - length(trim(Last_name))>0;

select Last_name, trim(Last_name) as Last_name 
from limpieza 
where  length(Last_name) - length(trim(Last_name)) > 0;

update Limpieza set Last_name  = trim(Last_name)
where  length(Last_name) - length(trim(Last_name)) > 0;

#espacios extras
update limpieza set area = replace(area,' ','    ');
call limp();

#modificaciones de espacio
select area from limpieza
where area regexp  '\\s{2,}';

#modificacion ensayo
select area, trim(regexp_replace(area,'\\s+',' '))as ensayo from limpieza;
#modificacion real
UPDATE limpieza set area = trim(regexp_replace(area,'\\s+',' '));
call limp();

#modificacion ensayo
select  Gender,
CASE
    when Gender = 'hombre' then 'male'
    when Gender = 'mujer' then 'female'
    else 'other'
END as gender1
from limpieza;

#MODIFICACION
 UPDATE LIMPIEZA SET Gender = case
     when Gender = 'hombre' then 'male'
     when Gender = 'mujer' then 'female'
     else 'other'
END;
 
call limp();

describe limpieza;

ALTER TABLE Limpieza modify column type text;

#ensayo type

select type,
case 
    when type = 1 then 'Remote'
    when type = 0 then 'Hybrid'
    Else 'Other'
End as ejemplo
from limpieza; 

# modificacion
update limpieza
set type = case 
    when type = 1 then 'Remote'
    when type = 0 then 'Hybrid'
    Else 'Other'
End;

call limp();

# ajustar formato de texto, los espacios en blanco el formato numero no lo permitira

select salary,
              cast(trim(replace (replace (salary,'$', ''),',', '')) as decimal(15,2)) as salary1 from limpieza;
# actualizacion
update limpieza set salary = cast(trim(replace (replace (salary,'$', ''),',', '')) as decimal(15,2));
call limp(); 

ALTER table limpieza modify column salary int null;
DESCRIBE LIMPIEZA;

SELECT birth_date from limpieza;

# fechas, buscamos patrones de fechas
select birth_date, case
    when birth_date like '%/%' then  date_format(str_to_date(birth_date,'%m/%d/%y'), '%Y-%m-%d')
	when birth_date like '%-%' then  date_format(str_to_date(birth_date,'%m-%d-%y'), '%Y-%m-%d')    
ELSE NULL
END AS  new_birth_date
from limpieza;

#actualizacion 
update limpieza
set birth_date = case
	when birth_date like '%/%' then  date_format(str_to_date(birth_date, '%m/%d/%Y'), '%Y-%m-%d')
	when birth_date like '%-%' then  date_format(str_to_date(birth_date, '%m-%d-%Y'), '%Y-%m-%d')    
ELSE NULL
end;
call limp();

ALTER TABLE limpieza Modify Column birth_date date;
describe limpieza;

select finish_date from limpieza;

#Explorando otras fechas y hora
 
 select finish_date, str_to_date(finish_date,'%Y-%m-%d %H:%i:%s') AS fecha FROM limpieza; -- convierte el valor en objeto de fecha (times tamp)
 
 select finish_date, date_format(str_to_date(finish_date,'%Y-%m-%d  %H:%i:%s'), '%Y-%m-%d') AS fecha from limpieza; -- objeto en formato fecha,luego
 select finish_date, str_to_date(finish_date, '%Y-%m-%d') AS fd from limpieza;-- separar solo las fechas 
 select finish_date, str_to_date(finish_date, '%H-%i-%s') AS hour_stamp from limpieza;-- separar solo la hora no funciona
 select finish_date, date_format(finish_date, '%H-%i-%s') AS hour_stamp from limpieza;-- separar solo la hora(marca el tiempo)
 
 select finish_date,
     date_format(finish_date, '%H') AS Hora,
     date_format(finish_date, '%i') AS minutos,
     date_format(finish_date,'%s')As segundos,
     date_format(finish_date,'%H:%i%s') AS hour_stamp
     from limpieza;


#diferencia entre timestamp y datetime
-- timestamp(YYYY-MM-DD HH-MM--SS)- DESDE: 1 DE ENERO DE 1970 A las 00:00:00 utc, hasta milesima de segundo
-- datetime desde el ano 1000 a 9999' no tiene en cuenta la zona horaria hasta segundo.*/

#tratar de hacer una copia de seguridad de la tabla

alter table Limpieza add column date_backup text ;

call limp();

update Limpieza set date_backup = finish_date;

select finish_date, str_to_date(finish_date, '%Y-%m-%d %H%:%i:%s') as fecha from limpieza;
 
UPDATE Limpieza set finish_date = str_to_date(finish_date, '%Y-%m-%d %H:%i:%s UTC')-- es lo que queremos transformar
WHERE finish_date <>'';
 
 alter table limpieza
       add column fecha date,
       add column hora time;
call limp();

update limpieza
set fecha = date (finish_date),
	hora = time (finish_date)
where finish_date is not null and finish_date <> '';

UPDATE limpieza set finish_date = null where finish_date = '';
       
       
alter table limpieza modify column  finish_date datetime;
describe limpieza;
 

#Hacer una columna para agregar datos de edad
alter table limpieza add column age INT;

#EJERCICIOS PREVIOS PARA conocer la dinamica de los calculos con fecha

select name, birth_date, start_date, timestampdiff(year, birth_date, start_date) as edad_de_ingreso from limpieza;

update Limpieza
set AGE = timestampdiff(year,birth_date, curdate());
call limp();
select name,birth_date, age from limpieza;


#construccion de correo electronico 
select concat(substring_index(name,' ',1),'_', substring(Last_name, 1, 2),'.', substring(type,1,1), '@consulting.com') as email from limpieza;
#adicionar a table
 
alter table limpieza add column email varchar(100);
call limp();
UPDATE limpieza SET email =concat(substring_index(name,' ',1),'_', substring(Last_name, 1, 2),'.', substring(type,1,1), '@consulting.com') ;


call limp();
#disenar y exportar el set de datos final
select Id_emp, Name, Last_name, age, gender, area, salary, email, finish_date FROM limpieza
where finish_date <= curdate() or finish_date is null
order by area,Last_name, name;

select area, count(*) as cantidad_empleados from limpieza
group by area
order by cantidad_empleados DESC;








	