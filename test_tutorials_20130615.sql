-- Modell zu einer Frage auf tutorials.de

drop table artikel;
drop table kategorie;
drop table gratisartikel;
drop table gratisartikel2artikel_oder_kat;
drop table artikel_2_kategorie;



create table artikel (
    id varchar2(10)
  , name varchar2(10)
);

insert into artikel values ('1a', 'Besen');
insert into artikel values ('1b', 'Schaufel');
insert into artikel values ('1c', 'Kombi');


create table kategorie (
    id varchar2(10)
  , name varchar2(10)
);
insert into kategorie values ('2a', 'Kat1');
insert into kategorie values ('2b', 'Kat2');
insert into kategorie values ('2c', 'Kat3');

create table gratisartikel (
    id varchar2(10)
  , name varchar2(10)
);
insert into gratisartikel values ('3a', '2Hefte');
insert into gratisartikel values ('3b', '3Hefte');
insert into gratisartikel values ('3c', '4Hefte');


create table gratisartikel2artikel_oder_kat (
    id number
  , artikel_kat_id varchar2(10)
  , gratisartikel varchar2(10)
);

insert into gratisartikel2artikel_oder_kat values (1, '1a', '3a');
insert into gratisartikel2artikel_oder_kat values (2, '1b', '3b');
insert into gratisartikel2artikel_oder_kat values (3, '1c', '3c');
insert into gratisartikel2artikel_oder_kat values (4, '2a', '3c');


create table artikel_2_kategorie (
    id number
  , artikelid varchar2(10)
  , katid varchar2(10)
);

insert into artikel_2_kategorie values (1, '1a', '2a');
insert into artikel_2_kategorie values (2, '1a', '2b');
insert into artikel_2_kategorie values (3, '1a', '2c');
insert into artikel_2_kategorie values (4, '1b', '2a');
insert into artikel_2_kategorie values (5, '1b', '2b');
insert into artikel_2_kategorie values (6, '1b', '2c');


select *
  from (select a.id artikel_id 
             , a.name artikel_name
			 , k.id kategorie_id
             , k.name kategorie_name
		  from artikel a
		  join artikel_2_kategorie ak
			on a.id = ak.artikelid
		  join kategorie k
			on ak.katid = k.id) aik
       join
       (select gak.id
             , gak.artikel_kat_id
             , gak.gratisartikel
             , g.id gratisartikel_id
             , g.name gratisartikel_name
          from gratisartikel g
          join gratisartikel2artikel_oder_kat gak
            on gak.gratisartikel = g.id) gak1
    on aik.artikel_id = gak1.artikel_kat_id
       or aik.kategorie_id = gak1.artikel_kat_id
;


subquery1.artikel_id = subquery2.artikel_kat_id
or subquery1.kategorie_id = subquery2.artikel_kat_id