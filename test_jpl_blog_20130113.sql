drop table member;

create table member(
    member_id number
  , block_age_max_nbr number
) tablespace test_ts pctfree 50 pctused 50;

begin
    for i in 1..200000 loop
        insert into member(member_id, block_age_max_nbr) values (1,1);
        commit;
    end loop;
end;
/
 
execute dbms_stats.gather_table_stats(user,'member',method_opt => 'for all columns size 1')

alter system flush BUFFER_CACHE;

alter session set “_serial_direct_read” = always;

-- serial direct reads
-- http://www.antognini.ch/2009/07/impact-of-direct-reads-on-delayed-block-cleanouts/

-- http://martinpreiss.blogspot.de/search/label/Blocks
-- table scan rows gotten: pro row piece
-- keine Erhöhung von table fetch continued row, wenn die Fortsetzung im gleichen Block erfolgt?


drop table member;

create table member (
  member_id number
, col_1 varchar2(4000)
, col_2 number
, col_3 number
, col_4 number
, col_5 number
, col_6 number
, col_7 number
, col_8 number
, col_9 number
, col_10 number
, col_11 number
, col_12 number
, col_13 number
, col_14 number
, col_15 number
, col_16 number
, col_17 number
, col_18 number
, col_19 number
, col_20 number
, col_21 number
, col_22 number
, col_23 number
, col_24 number
, col_25 number
, col_26 number
, col_27 number
, col_28 number
, col_29 number
, col_30 number
, col_31 number
, col_32 number
, col_33 number
, col_34 number
, col_35 number
, col_36 number
, col_37 number
, col_38 number
, col_39 number
, col_40 number
, col_41 number
, col_42 number
, col_43 number
, col_44 number
, col_45 number
, col_46 number
, col_47 number
, col_48 number
, col_49 number
, col_50 number
, col_51 number
, col_52 number
, col_53 number
, col_54 number
, col_55 number
, col_56 number
, col_57 number
, col_58 number
, col_59 number
, col_60 number
, col_61 number
, col_62 number
, col_63 number
, col_64 number
, col_65 number
, col_66 number
, col_67 number
, col_68 number
, col_69 number
, col_70 number
, col_71 number
, col_72 number
, col_73 number
, col_74 number
, col_75 number
, col_76 number
, col_77 number
, col_78 number
, col_79 number
, col_80 number
, col_81 number
, col_82 number
, col_83 number
, col_84 number
, col_85 number
, col_86 number
, col_87 number
, col_88 number
, col_89 number
, col_90 number
, col_91 number
, col_92 number
, col_93 number
, col_94 number
, col_95 number
, col_96 number
, col_97 number
, col_98 number
, col_99 number
, col_100 number
, col_101 number
, col_102 number
, col_103 number
, col_104 number
, col_105 number
, col_106 number
, col_107 number
, col_108 number
, col_109 number
, col_110 number
, col_111 number
, col_112 number
, col_113 number
, col_114 number
, col_115 number
, col_116 number
, col_117 number
, col_118 number
, col_119 number
, col_120 number
, col_121 number
, col_122 number
, col_123 number
, col_124 number
, col_125 number
, col_126 number
, col_127 number
, col_128 number
, col_129 number
, col_130 number
, col_131 number
, col_132 number
, col_133 number
, col_134 number
, col_135 number
, col_136 number
, col_137 number
, col_138 number
, col_139 number
, col_140 number
, col_141 number
, col_142 number
, col_143 number
, col_144 number
, col_145 number
, col_146 number
, col_147 number
, col_148 number
, col_149 number
, col_150 number
, col_151 number
, col_152 number
, col_153 number
, col_154 number
, col_155 number
, col_156 number
, col_157 number
, col_158 number
, col_159 number
, col_160 number
, col_161 number
, col_162 number
, col_163 number
, col_164 number
, col_165 number
, col_166 number
, col_167 number
, col_168 number
, col_169 number
, col_170 number
, col_171 number
, col_172 number
, col_173 number
, col_174 number
, col_175 number
, col_176 number
, col_177 number
, col_178 number
, col_179 number
, col_180 number
, col_181 number
, col_182 number
, col_183 number
, col_184 number
, col_185 number
, col_186 number
, col_187 number
, col_188 number
, col_189 number
, col_190 number
, col_191 number
, col_192 number
, col_193 number
, col_194 number
, col_195 number
, col_196 number
, col_197 number
, col_198 number
, col_199 number
, col_200 number
, col_201 number
, col_202 number
, col_203 number
, col_204 number
, col_205 number
, col_206 number
, col_207 number
, col_208 number
, col_209 number
, col_210 number
, col_211 number
, col_212 number
, col_213 number
, col_214 number
, col_215 number
, col_216 number
, col_217 number
, col_218 number
, col_219 number
, col_220 number
, col_221 number
, col_222 number
, col_223 number
, col_224 number
, col_225 number
, col_226 number
, col_227 number
, col_228 number
, col_229 number
, col_230 number
, col_231 number
, col_232 number
, col_233 number
, col_234 number
, col_235 number
, col_236 number
, col_237 number
, col_238 number
, col_239 number
, col_240 number
, col_241 number
, col_242 number
, col_243 number
, col_244 number
, col_245 number
, col_246 number
, col_247 number
, col_248 number
, col_249 number
, col_250 number
, col_251 number
, col_252 number
, col_253 number
, col_254 number
, col_255 number
, col_256 number
, col_257 number
, col_258 number
, col_259 number
, col_260 number
, col_261 number
, col_262 number
, col_263 number
, col_264 number
, col_265 number
, col_266 number
, col_267 number
, col_268 number
, col_269 number
, col_270 number
, col_271 number
, col_272 number
, col_273 number
, col_274 number
, col_275 number
, col_276 number
, col_277 number
, col_278 number
, col_279 number
, col_280 number
, col_281 number
, col_282 number
, col_283 number
, col_284 number
, col_285 number
, col_286 number
, col_287 number
, col_288 number
, col_289 number
, col_290 number
, col_291 number
, col_292 number
, col_293 number
, col_294 number
, col_295 number
, col_296 number
, col_297 number
, col_298 number
, col_299 number
, col_300 number
, block_age_max_nbr number
);

begin
    for i in 1..200 loop
        insert into member(member_id, block_age_max_nbr) values (1,1);
        commit;
    end loop;
end;
/
 
execute dbms_stats.gather_table_stats(user,'member',method_opt => 'for all columns size 1')

alter system flush BUFFER_CACHE;

alter session set “_serial_direct_read” = true;

select max(block_age_max_nbr) from member;




-- Nachtrag 16.01.2013


drop table member;

create table member (
  member_id number
, col_1 varchar2(4000)
, col_2 number
, col_3 number
, col_4 number
, col_5 number
, col_6 number
, col_7 number
, col_8 number
, col_9 number
, col_10 number
, col_11 number
, col_12 number
, col_13 number
, col_14 number
, col_15 number
, col_16 number
, col_17 number
, col_18 number
, col_19 number
, col_20 number
, col_21 number
, col_22 number
, col_23 number
, col_24 number
, col_25 number
, col_26 number
, col_27 number
, col_28 number
, col_29 number
, col_30 number
, col_31 number
, col_32 number
, col_33 number
, col_34 number
, col_35 number
, col_36 number
, col_37 number
, col_38 number
, col_39 number
, col_40 number
, col_41 number
, col_42 number
, col_43 number
, col_44 number
, col_45 number
, col_46 number
, col_47 number
, col_48 number
, col_49 number
, col_50 number
, col_51 number
, col_52 number
, col_53 number
, col_54 number
, col_55 number
, col_56 number
, col_57 number
, col_58 number
, col_59 number
, col_60 number
, col_61 number
, col_62 number
, col_63 number
, col_64 number
, col_65 number
, col_66 number
, col_67 number
, col_68 number
, col_69 number
, col_70 number
, col_71 number
, col_72 number
, col_73 number
, col_74 number
, col_75 number
, col_76 number
, col_77 number
, col_78 number
, col_79 number
, col_80 number
, col_81 number
, col_82 number
, col_83 number
, col_84 number
, col_85 number
, col_86 number
, col_87 number
, col_88 number
, col_89 number
, col_90 number
, col_91 number
, col_92 number
, col_93 number
, col_94 number
, col_95 number
, col_96 number
, col_97 number
, col_98 number
, col_99 number
, col_100 number
, col_101 number
, col_102 number
, col_103 number
, col_104 number
, col_105 number
, col_106 number
, col_107 number
, col_108 number
, col_109 number
, col_110 number
, col_111 number
, col_112 number
, col_113 number
, col_114 number
, col_115 number
, col_116 number
, col_117 number
, col_118 number
, col_119 number
, col_120 number
, col_121 number
, col_122 number
, col_123 number
, col_124 number
, col_125 number
, col_126 number
, col_127 number
, col_128 number
, col_129 number
, col_130 number
, col_131 number
, col_132 number
, col_133 number
, col_134 number
, col_135 number
, col_136 number
, col_137 number
, col_138 number
, col_139 number
, col_140 number
, col_141 number
, col_142 number
, col_143 number
, col_144 number
, col_145 number
, col_146 number
, col_147 number
, col_148 number
, col_149 number
, col_150 number
, col_151 number
, col_152 number
, col_153 number
, col_154 number
, col_155 number
, col_156 number
, col_157 number
, col_158 number
, col_159 number
, col_160 number
, col_161 number
, col_162 number
, col_163 number
, col_164 number
, col_165 number
, col_166 number
, col_167 number
, col_168 number
, col_169 number
, col_170 number
, col_171 number
, col_172 number
, col_173 number
, col_174 number
, col_175 number
, col_176 number
, col_177 number
, col_178 number
, col_179 number
, col_180 number
, col_181 number
, col_182 number
, col_183 number
, col_184 number
, col_185 number
, col_186 number
, col_187 number
, col_188 number
, col_189 number
, col_190 number
, col_191 number
, col_192 number
, col_193 number
, col_194 number
, col_195 number
, col_196 number
, col_197 number
, col_198 number
, col_199 number
, col_200 number
, col_201 number
, col_202 number
, col_203 number
, col_204 number
, col_205 number
, col_206 number
, col_207 number
, col_208 number
, col_209 number
, col_210 number
, col_211 number
, col_212 number
, col_213 number
, col_214 number
, col_215 number
, col_216 number
, col_217 number
, col_218 number
, col_219 number
, col_220 number
, col_221 number
, col_222 number
, col_223 number
, col_224 number
, col_225 number
, col_226 number
, col_227 number
, col_228 number
, col_229 number
, col_230 number
, col_231 number
, col_232 number
, col_233 number
, col_234 number
, col_235 number
, col_236 number
, col_237 number
, col_238 number
, col_239 number
, col_240 number
, col_241 number
, col_242 number
, col_243 number
, col_244 number
, col_245 number
, col_246 number
, col_247 number
, col_248 number
, col_249 number
, col_250 number
, col_251 number
, col_252 number
, col_253 number
, col_254 number
, col_255 number
, col_256 number
, col_257 number
, col_258 number
, col_259 number
, col_260 number
, col_261 number
, col_262 number
, col_263 number
, col_264 number
, col_265 number
, col_266 number
, col_267 number
, col_268 number
, col_269 number
, col_270 number
, col_271 number
, col_272 number
, col_273 number
, col_274 number
, col_275 number
, col_276 number
, col_277 number
, col_278 number
, col_279 number
, col_280 number
, col_281 number
, col_282 number
, col_283 number
, col_284 number
, col_285 number
, col_286 number
, col_287 number
, col_288 number
, col_289 number
, col_290 number
, col_291 number
, col_292 number
, col_293 number
, col_294 number
, col_295 number
, col_296 number
, col_297 number
, col_298 number
, col_299 number
, col_300 number
, col_301 varchar2(100)
, block_age_max_nbr number
) pctfree 0 tablespace test_ts;

begin
    for i in 1..100 loop
        insert into member(member_id, block_age_max_nbr) values (1,1);
        commit;
    end loop;
end;
/

update member set col_301 = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' ;
 
execute dbms_stats.gather_table_stats(user,'member',method_opt => 'for all columns size 1')

alter system flush BUFFER_CACHE;

alter session set “_serial_direct_read” = true;



select max(member_id) from member;
select max(block_age_max_nbr) from member;

NAME                                                             VALUE_BEGIN  VALUE_END       DIFF
---------------------------------------------------------------- ----------- ---------- ----------
file io wait time                                                    4818882    4824857       5975
bytes sent via SQL*Net to client                                       13716      14255        539
bytes received via SQL*Net from client                                 28244      28559        315
table scan rows gotten                                                 52625      52835        210
consistent gets                                                        43723      43730          7
session logical reads                                                  63710      63717          7
physical reads                                                          1251       1257          6
consistent gets direct                                                  1851       1856          5
no work - consistent read gets                                         16598      16603          5
table scan blocks gotten                                                1095       1100          5
non-idle wait count                                                     1196       1201          5
physical reads direct                                                     57         62          5
user calls                                                                79         82          3
consistent gets from cache                                             41872      41874          2
SQL*Net roundtrips to/from client                                         46         48          2
DB time                                                                 1368       1370          2
physical read IO requests                                               1063       1065          2
calls to kcmgcs                                                          460        462          2
parse time elapsed                                                       186        188          2
physical read total IO requests                                         1063       1065          2
CPU used when call started                                               584        585          1
recursive calls                                                        91254      91255          1
parse time cpu                                                            57         58          1
execute count                                                           9733       9734          1
opened cursors cumulative                                               8831       8832          1
consistent gets from cache (fastpath)                                  14471      14472          1
Number of read IOs issued                                                 13         14          1
calls to get snapshot scn: kcmgss                                       8939       8940          1
free buffer requested                                                   1478       1479          1
enqueue requests                                                        1081       1082          1
enqueue releases                                                        1080       1081          1
physical reads cache                                                    1194       1195          1
CPU used by this session                                                 584        585          1

NAME                                                             VALUE_BEGIN  VALUE_END       DIFF
---------------------------------------------------------------- ----------- ---------- ----------
file io wait time                                                    4841373    4853678      12305
table scan rows gotten                                                 52835      57875       5040
bytes sent via SQL*Net to client                                       14426      14973        547
bytes received via SQL*Net from client                                 28861      29184        323
session logical reads                                                  63721      63928        207
consistent gets                                                        43730      43937        207
consistent gets direct                                                  1856       2061        205
no work - consistent read gets                                         16603      16808        205
table scan blocks gotten                                                1100       1205        105
buffer is not pinned count                                             32887      32987        100
table fetch continued row                                                264        288         24
physical reads                                                          1260       1266          6
non-idle wait count                                                     1209       1214          5
physical reads direct                                                     62         67          5
user calls                                                                84         87          3
SQL*Net roundtrips to/from client                                         49         51          2
consistent gets from cache                                             41874      41876          2
physical read total IO requests                                         1068       1070          2
physical read IO requests                                               1068       1070          2
calls to kcmgcs                                                          462        464          2
enqueue requests                                                        1085       1086          1
non-idle wait time                                                       747        748          1
user I/O wait time                                                       490        491          1
recursive calls                                                        91275      91276          1
execute count                                                           9735       9736          1
opened cursors cumulative                                               8833       8834          1
consistent gets from cache (fastpath)                                  14472      14473          1
enqueue releases                                                        1084       1085          1
Number of read IOs issued                                                 14         15          1
calls to get snapshot scn: kcmgss                                       8941       8942          1
free buffer requested                                                   1482       1483          1
physical reads cache                                                    1198       1199          1

41 Zeilen ausgewõhlt.


NAME                                                             VALUE_BEGIN  VALUE_END       DIFF
---------------------------------------------------------------- ----------- ---------- ----------
table scans (long tables)                                                 14         15          1
table scans (direct read)                                                 14         15          1
parse count (total)                                                     1244       1245          1
parse count (hard)                                                       213        214          1
