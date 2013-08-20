-- 28.11.2012

drop table test_chaining;

create table test_chaining (
  col_1 varchar2(4000)
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
);

insert into test_chaining (col_300) values (1);

analyze table test_chaining compute statistics;


SQL> insert into test_chaining (col_300) values (1);

1 Zeile wurde erstellt.

Abgelaufen: 00:00:00.17
SQL>
SQL> analyze table test_chaining compute statistics;

Tabelle wurde analysiert.

Abgelaufen: 00:00:00.25
SQL> select * from user_tables where table_name = 'TEST_CHAINING';

TABLE_NAME                     TABLESPACE_NAME                CLUSTER_NAME                   IOT
------------------------------ ------------------------------ ------------------------------ ---
TEST_CHAINING                  USERS

Abgelaufen: 00:00:00.13
SQL> truncate table test_chaining;

Tabelle mit TRUNCATE geleert.

Abgelaufen: 00:00:00.19
SQL> insert into test_chaining (col_300) select 1 from dual connect by level <= 10000;

10000 Zeilen wurden erstellt.

Abgelaufen: 00:00:00.34
SQL> commit;

Transaktion mit COMMIT abgeschlossen.

Abgelaufen: 00:00:00.02
SQL> analyze table test_chaining compute statistics;

Tabelle wurde analysiert.

Abgelaufen: 00:00:00.17
SQL> select num_rows, blocks, chain_cnt from user_tables where table_name = 'TEST_CHAINING';

  NUM_ROWS     BLOCKS  CHAIN_CNT
---------- ---------- ----------
     10000        496          0


insert into test_chaining 
select lpad('*', 4000, '*')
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
, 1
from dual connect by level <= 10000;