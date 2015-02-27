# ABSTRACT: Driver for the Chinese tagset of the CoNLL 2006 & 2007 Shared Tasks (derived from the Academia Sinica Treebank).
# Documentation in Huang, Chen, Lin: Corpus on Web: Introducing the First Tagged and Balanced Chinese Corpus.
# Copyright © 2007, 2015 Dan Zeman <zeman@ufal.mff.cuni.cz>

package Lingua::Interset::Tagset::ZH::Conll;
use strict;
use warnings;
our $VERSION = '2.041';

use utf8;
use open ':utf8';
use namespace::autoclean;
use Moose;
extends 'Lingua::Interset::Tagset::Conll';



#------------------------------------------------------------------------------
# Returns the tagset id that should be set as the value of the 'tagset' feature
# during decoding. Every derived class must (re)define this method! The result
# should correspond to the last two parts in package name, lowercased.
# Specifically, it should be the ISO 639-2 language code, followed by '::' and
# a language-specific tagset id. Example: 'cs::multext'.
#------------------------------------------------------------------------------
sub get_tagset_id
{
    return 'zh::conll';
}



#------------------------------------------------------------------------------
# Creates atomic drivers for surface features.
#------------------------------------------------------------------------------
sub _create_atoms
{
    my $self = shift;
    my %atoms;
    # PART OF SPEECH ####################
    $atoms{pos} = $self->create_atom
    (
        'surfeature' => 'pos',
        'decode_map' =>
        {
            # noun or pronoun
            # N Naa: 水 = water, 地 = ground, 茶 = tea, 土地 = land, 食物 = food
            # N Nab: 人 = people, 者 = person, 媽媽 = mother, 地方 = place, 爸爸 = father
            # N Nac: 國家 = country, 政府 = government, 問題 = issue, 事 = thing, 社會 = society
            # N Nad: 時候 = time, 時間 = time, 文化 = culture, 生活 = life, 歷史 = history
            # N Naea: 們 = they, 人人 = everyone, 國人 = people, 百貨 = merchandise, 飲食 = diet/food
            # N Naeb: 錢 = money, 人民 = people, 人們 = people, 海鮮 = seafood, 父母 = parents
            'Naa'  => ['pos' => 'noun', 'nountype' => 'com'],
            'Nab'  => ['pos' => 'noun', 'nountype' => 'com', 'other' => {'subpos' => 'ab'}],
            'Nac'  => ['pos' => 'noun', 'nountype' => 'com', 'other' => {'subpos' => 'ac'}],
            'Nad'  => ['pos' => 'noun', 'nountype' => 'com', 'other' => {'subpos' => 'ad'}],
            'Naea' => ['pos' => 'noun', 'nountype' => 'com', 'other' => {'subpos' => 'aea'}],
            'Naeb' => ['pos' => 'noun', 'nountype' => 'com', 'other' => {'subpos' => 'aeb'}],
            # N Nba: 中共 = Chinese Communist Party, 國民黨 = Kuomintang, 民進黨 = DPP, 老包 = Old Package, 布希 = Bush
            # N Nbc: 李 Lǐ, 林 Lín, 郝 Hǎo, 張 Zhāng, 于 Yú (probably Chinese surnames?)
            'Nba'  => ['pos' => 'noun', 'nountype' => 'prop'],
            'Nbc'  => ['pos' => 'noun', 'nountype' => 'prop', 'other' => {'subpos' => 'bc'}],
            # location noun (including some proper nouns, e.g. Feizhou = Africa)
            # N Nca: 台灣 = Taiwan, 中國 = China, 美國 = USA, 日本 = Japan, 蘇聯 = Soviet Union
            # N Ncb: 公司 = company, 世界 = world, 家 = home, 國 = country, 公園 = park
            # N Ncc: 國內 = domestic, 國際 = international, 民間 = folk, 國外 = foreign, 眼前 = present
            # N Ncda: 上 shàng = on, 裡 lǐ = in, 中 zhōng = in, 內 nèi = within, 邊 biān = edge, border
            # N Ncdb: 這裡 zhèlǐ = here, 那裡 nàlǐ = there, 西方 xīfāng = west, 哪裡 nǎlǐ = where, 內部 nèibù = interior
            # N Nce: 當地 = local, 兩岸 = both sides, 全球 = global, 外國 = foreign, 本土 = local
            'Nca'  => ['pos' => 'noun', 'advtype' => 'loc'],
            'Ncb'  => ['pos' => 'noun', 'advtype' => 'loc', 'other' => {'subpos' => 'cb'}],
            'Ncc'  => ['pos' => 'noun', 'advtype' => 'loc', 'other' => {'subpos' => 'cc'}],
            'Ncda' => ['pos' => 'noun', 'advtype' => 'loc', 'other' => {'subpos' => 'cda'}],
            'Ncdb' => ['pos' => 'noun', 'advtype' => 'loc', 'other' => {'subpos' => 'cdb'}],
            'Nce'  => ['pos' => 'noun', 'advtype' => 'loc', 'other' => {'subpos' => 'ce'}],
            # time noun
            # N Ndaaa: 年代 = era, １７世紀 = 17th century, １９世紀, １８世紀, １５世紀
            # N Ndaab: 民國 = Republic, 明 = Ming, 清 = Qing, 明朝 = Ming Dynasty, 清朝 = Qing Dynasty
            # N Ndaac: 光緒 = Guangxu, 明治 = Meiji, 江戶 = Edo, 寬永 = Kanei, 萬曆 = Wanli
            # N Ndaad: 西元 xīyuán = AD, 一九九０年 = 1990, 七十九年 = 1990, １９９２年 = 1992, 七十六年 = 76 years (of the Republic?) / 1987
            # N Ndaba: 今年 = this year, 去年 = last year, 明年 = next year, 隔年 = next year, 元年 = first year
            # N Ndabb: 春天 = spring, 夏天 = summer, 秋天 = fall, 冬天 = winter, 春 = spring
            # N Ndabc: 月 = month, 十月 = October, 十一月 = November, 九月 = September, 八月 = August
            # N Ndabd: 昨天 = yesterday, 今天 = today, 昨日 = yesterday, 今日 = today, 明天 = tomorrow
            # N Ndabe: 當時 = at the time, 同時 = at the same time, 下午 = in the afternoon, 晚上 = at night, 上午 = morning
            # N Ndabf: 季 = season, 當年 = that year, 際 = occasion, 假日 = holiday, 新年 = New Year
            # N Ndbb: 末期 = late, 後 = later (only these two words, each occurred once)
            # N Ndc: 盤中 = middle of the day, 戰後 = after the war, 晚間 = evening, 日後 = future, 午後 = afternoon
            # N Ndda: 過去 = past, 以前 = before, 古代 = ancient times, 當時 = at the time, 從前 = before
            # N Nddb: 後來 = later, 未來 = future, 不久 = soon, 將來 = future, 以後 = after
            # N Nddc: 目前 = for now, 現在 = right now, 最後 = finally, 如今 = now, 最近 = recently
            'Ndaaa' => ['pos' => 'noun', 'advtype' => 'tim'],
            'Ndaab' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'daab'}],
            'Ndaac' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'daac'}],
            'Ndaad' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'daad'}],
            'Ndaba' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'daba'}],
            'Ndabb' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dabb'}],
            'Ndabc' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dabc'}],
            'Ndabd' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dabd'}],
            'Ndabe' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dabe'}],
            'Ndabf' => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dabf'}],
            'Ndbb'  => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dbb'}],
            'Ndc'   => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dc'}],
            'Ndda'  => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'dda'}],
            'Nddb'  => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'ddb'}],
            'Nddc'  => ['pos' => 'noun', 'advtype' => 'tim', 'other' => {'subpos' => 'ddc'}],
            # classifier (measure word)
            ###!!! There are much less occurrences than I would expect for this sort of words!
            # N Nfa: 個 gè (months), 次 cì (times), 句 jù (sentences), 隻 zhī (only), 頁 yè (pages)
            # N Nfc: 攤 = stalls, 項 = items, 席 = seats
            # N Nfd: 點 = points, 層 = layers, 段 = sections, 些 = some
            # N Nfe: 杯 = cups, 桶 = buckets
            # N Nfg: 年 = years, 歲 = years, 元 = yuans, 美元 = dollars, 天 = days
            # N Nfh: 成, 股 = shares
            # N Nfi: 次 = times, 場 = fields
            'Nfa' => ['pos' => 'noun', 'nountype' => 'class'],
            'Nfc' => ['pos' => 'noun', 'nountype' => 'class', 'other' => {'subpos' => 'fc'}],
            'Nfd' => ['pos' => 'noun', 'nountype' => 'class', 'other' => {'subpos' => 'fd'}],
            'Nfe' => ['pos' => 'noun', 'nountype' => 'class', 'other' => {'subpos' => 'fe'}],
            'Nfg' => ['pos' => 'noun', 'nountype' => 'class', 'other' => {'subpos' => 'fg'}],
            'Nfh' => ['pos' => 'noun', 'nountype' => 'class', 'other' => {'subpos' => 'fh'}],
            'Nfi' => ['pos' => 'noun', 'nountype' => 'class', 'other' => {'subpos' => 'fi'}],
            # pronoun
            # N Nhaa: 我 wǒ = I, 他 tā = he, 我們 wǒmen = we, 你 nǐ = you, 他們 tāmen = they
            # N Nhab: 自己 zìjǐ = oneself, 大家 dàjiā = everyone, 雙方 shuāngfāng = both sides, 個人 gèrén = person, 自我 zìwǒ = self
            # N Nhac: 您 nín = you, 敝國 bìguó = mine, 筆者 bǐzhě = author/I, 貴國 guìguó = your, 本人 běnrén = myself/himself
            # N Nhb: 誰 shuí = who, 您 nín = you, 筆者 bǐzhě = author/I, 孰 shú = what, 各人 gèrén = everyone
            # N Nhc: 之 zhī = it, 前者 = the former, 後者 = the latter, 凡此種種 = all these, 兩者 = both
            'Nhaa' => ['pos' => 'noun', 'prontype' => 'prs'],
            'Nhab' => ['pos' => 'noun', 'prontype' => 'prs', 'reflex' => 'reflex'],
            'Nhac' => ['pos' => 'noun', 'prontype' => 'prs', 'politeness' => 'pol'],
            'Nhb'  => ['pos' => 'noun', 'prontype' => 'int'],
            'Nhc'  => ['pos' => 'noun', 'prontype' => 'prn', 'gender' => 'neut'],
            # verbal noun
            # N Nv1: 發展 = development, 服務 = service, 醫療 = medical treatment, 攻擊 = attack, 經營 = run
            # N Nv2: 注意 = attention, 同意 = consent, 認同 = identification, 欣賞 = appreciation, 了解 = understanding
            # N Nv3: 有關 = relation, 重視 = importance, 優惠 = preference, 認識 = understanding, 領先 = lead
            # N Nv4: 旅遊 = travel, 購物 = shopping, 觀光 = sightseeing, 旅行 = travel, 反彈 = rally
            'Nv1' => ['pos' => 'noun', 'verbform' => 'ger'],
            'Nv2' => ['pos' => 'noun', 'verbform' => 'ger', 'other' => {'subpos' => 'v2'}],
            'Nv3' => ['pos' => 'noun', 'verbform' => 'ger', 'other' => {'subpos' => 'v3'}],
            'Nv4' => ['pos' => 'noun', 'verbform' => 'ger', 'other' => {'subpos' => 'v4'}],
            # A A adjective
            # Examples: 主要 = main, 一般 = general, 共同 = common, 最佳 = optimal, 唯一 = the only
            'A'    => ['pos' => 'adj'],
            # determiner
            # anaphoric determiner (this, that)
            # Ne Nep: 這 zhè = this, 此 cǐ = this, 其 qí = its, 什麼 shénme = any, 那 nà = that
            'Nep'  => ['pos' => 'adj', 'prontype' => 'dem'],
            # classifying determiner (much, half)
            # Ne Neqa: 全 quán = all, 許多 xǔduō = a lot of, 這些 zhèxiē = these, 一些 yīxiē = some, 其他 qítā = other
            # Ne Neqb: 多 duō = many, 以上 = more/above, 左右 zuǒyòu = about/approximately, 許 xǔ = perhaps, 上下 shàngxià = up and down
            'Neqa' => ['pos' => 'adj', 'prontype' => 'prn'],
            'Neqb' => ['pos' => 'adj', 'prontype' => 'prn', 'other' => {'subpos' => 'qb'}],
            # specific determiner (you, shang, ge = every)
            # Ne Nes: 各 gè = each, 有 yǒu = there is, 該 gāi = that, 本 běn = this, 另 lìng = other
            'Nes' => ['pos' => 'adj', 'prontype' => 'prn', 'other' => {'subpos' => 's'}],
            # numeric determiner (one, two, three)
            # Ne Neu: 一 yī = one, 二 èr = two, 兩 liǎng = two, 三 sān = three, 四 sì = four
            'Neu' => ['pos' => 'num', 'numtype' => 'card'],
            # verb
            'V'   => ['pos' => 'verb'],
            # adverb
            # D Daa: 只 = only, 約 = approximately, 才 = only, 共 = altogether, 僅 = only
            # D Dab: 都 = all, 所, 均 = all, 皆 = all, 完全 = entirely
            # D Dbaa: 是 = is, 會 = can/will, 可能 = maybe, 不會 = will not, 一定 = for sure
            # D Dbab: 要 = want, 能 = can, 可以 = can, 可 = can, 來 = come
            # D Dbb: 也 = also, 還 = also, 則 = then, 卻 = yet, 並 = and
            # D Dbc: 看起來 = looks, 看來 = seems, 說起來 = speaks, 聽起來 = sounds, 吃起來 = tastes
            # D Dc: 不 = not, 未 = not, 沒有 = there is no, 沒 = not, 非 = non-
            # D Dd: 就 = then, 又 = again, 已 = already, 將 = will, 才 = only
            # D Dfa: 很 = very, 最 = most, 更 = more, 較 = relatively, 非常 = very much
            # D Dfb: 一點 = a little, 極了 = extremely, 些 = some, 得很 = very, 多 = more
            # D Dg: 一路 = all the way, 到處 = everywhere, 四處 = around, 處處 = everywhere, 當場 = on the spot
            # D Dh: 如何 = how, 一起 = together, 更 = more, 分別 = respectively, 這麼 = so
            # D Dj: 為什麼 = why, 是否 = whether, 怎麼 = how, 為何 = why, 有沒有 = is there?
            # D Dk: 結果 = result, 那 = then, 據說 = reportedly, 據了解 = it is understood that, 那麼 = then
            'Daa'  => ['pos' => 'adv'],
            'Dab'  => ['pos' => 'adv', 'other' => {'subpos' => 'ab'}],
            'Dbaa' => ['pos' => 'adv', 'other' => {'subpos' => 'baa'}],
            'Dbab' => ['pos' => 'adv', 'other' => {'subpos' => 'bab'}],
            'Dbb'  => ['pos' => 'adv', 'other' => {'subpos' => 'bb'}],
            'Dbc'  => ['pos' => 'adv', 'other' => {'subpos' => 'bc'}],
            'Dc'   => ['pos' => 'adv', 'negativeness' => 'neg'],
            'Dd'   => ['pos' => 'adv', 'other' => {'subpos' => 'd'}],
            'Dfa'  => ['pos' => 'adv', 'other' => {'subpos' => 'fa'}],
            'Dfb'  => ['pos' => 'adv', 'other' => {'subpos' => 'fb'}],
            'Dg'   => ['pos' => 'adv', 'other' => {'subpos' => 'g'}],
            'Dh'   => ['pos' => 'adv', 'other' => {'subpos' => 'h'}],
            'Dj'   => ['pos' => 'adv', 'prontype' => 'int'],
            'Dk'   => ['pos' => 'adv', 'other' => {'subpos' => 'k'}],
            # measure word, quantifier
            # DM DM: 一個 yīgè = a, 這個 zhège = this one, 這種 zhèzhǒng = this kind, 個 gè, 一種 yīzhǒng = one kind
            ###!!! There ought to be a better solution!
            'DM'  => ['pos' => 'adj', 'nountype' => 'class'],
            # postposition (qian = before)
            # Ng Ng: 中 zhōng = middle, 時 shí = during, 後 hòu = after, 上 shàng = on, 前 qián = ago
            'Ng'  => ['pos' => 'adp', 'adpostype' => 'post'],
            # preposition (66 kinds, 66 different tags)
            # P P01: 承, 似, 承蒙, 為, 深為 (like, thanks to, for) max 3 occ.
            # P P02: 被, 受, 為, 深受, 備受 (for, by) max 588 occ.
            # P P03: 為 wèi, 為了 wèile (for, in order to) max 354 occ.
            # P P04: 給 gěi, 對 duì (to, for) max 132 occ.
            # P P06: 由 yóu, 遭, 改由, 每逢 (from, by, instead of) max 492 occ.
            # P P07: 把 bǎ, 將 jiāng (to) max 537 occ.
            # P P08: 拿 ná, 拿著, 直至 (take, hold, until, up to) max 8 occ.
            # P P09: 管, 尤以 () max 2 occ.
            # P P10: 為, 作 (for, as) max 6 occ.
            # P P11: 以 yǐ (with) max 990 occ.
            # P P12: 自從 (since) max 23 occ.
            # P P13: 等, 待, 逢, 每當, 趁 (wait, etc., whenever) max 19 occ.
            # P P14: 有 yǒu (there is) max 11 occ.
            # P P15: 離, 距, 距離, 臨, 去 (from, off, apart) max 21 occ.
            # P P16: 當 dāng (when, as) max 150 occ.
            # P P17: 打從, 打 dǎ () max 1 occ.
            # P P18: 直到, 等到, 直至, 及至 (until) max 44 occ.
            # P P19: 從 cóng (from) max 514 occ.
            # P P20: 就 jiù (on) max 37 occ.
            # P P21: 在 zài (in, at) max 3616 occ.
            # P P22: 繼 jì (following) max 10 occ.
            # P P23: 於 yú (to, in, on) max 569 occ.
            # P P24: 沿著 yánzhe, 沿, 跟, 延著 (along) max 29 occ.
            # P P25: 順著 shùnzhe, 循, 循著, 順 (following, along) max 5 occ.
            # P P26: 經 jīng, 經過, 經由, 業經, 一經 (after) max 66 occ.
            # P P27: 靠 kào, 靠著 (by, near, against) max 24 occ.
            # P P28: 朝 cháo, 假, 朝著 (towards) max 8 occ.
            # P P29: 朝 cháo, 朝著 (towards) max 2 occ.
            # P P30: 往 wǎng (to, towards) max 71 occ.
            # P P31: 對 duì, 針對, 對著, 針對了 (to, against) max 784 occ.
            # P P32: 對於 duìyú (for, about, regarding) max 110 occ.
            # P P35: 與 yǔ, 和 hé (versus, and, with) max 424 occ.
            # P P36: 代, 跟著 (on behalf of, following, in accord with) max 3 occ.
            # P P37: 替 tì, 幫 bāng (for, on behalf of, with the help of) max 62 occ.
            # P P38: 藉 jí, 藉著, 憑, 藉由, 憑藉 (by means of, through, based on, with) max 20 occ.
            # P P39: 用 yòng, 透過 (using, through) max 191 occ.
            # P P40: 基於 (because of, due to) max 15 occ.
            # P P41: 至於 zhìyú, 有關, 關於 (touching, as for, with respect to) max 95 occ.
            # P P42: 依 yī, 按, 照, 依著, 照著 (according to) max 75 occ.
            # P P43: 據 jù, 根據, 依據, 依照, 按照 (according to) max 97 occ.
            # P P44: 依循, 比照, 仿照 (following, in contrast to, cf.) max 2 occ.
            # P P45: 逐 (individually, one by one) max 2 occ.
            # P P46: 視 shì, 每隔 (depending on) max 26 occ.
            # P P47: 如 rú (according to) max 164 occ.
            # P P48: 有如 yǒurú, 一如, 如同, 似, 猶如 (like) max 7 occ.
            # P P49: 比 bǐ, 較, 比起, 相對於 (comparison particle) max 140 occ.
            # P P50: 除了 chúle, 除 chú (apart from, except) max 129 occ.
            # P P51: 連同 (together with, along of) max 1 occ.
            # P P52: 因 yīn, 因著 yīnzhe, 因為 yīnwèi (because of) max 7 occ.
            # P P53: 途經, 隨著 (via) max 2 occ.
            # P P54: 例如 lìrú, 譬如, 比如, 諸如, 誠如 (for example, such as) max 61 occ.
            # P P55: 像 xiàng, 好像 (like) max 169 occ.
            # P P58: 隨著 suízhe, 隨 (along with, along of) max 52 occ.
            # P P59: 自 zì (from, since) max 129 occ.
            # P P60: 遭 zāo, 慘遭, 險遭, 遭到, 遭受 (missing, suffering from) max 47 occ.
            # P P61: 到 dào, 至, 迄, 到了, 去 (to, up to, until) max 334 occ.
            # P P62: 向 xiàng, 向著 xiàngzhe (to, toward) max 355 occ.
            # P P63: 跟 gēn, 跟著 gēnzhe (with) max 141 occ.
            # P P64: 隨同, 偕 (accompanying) max 4 occ.
            # P P65: 隔 gé (at a distance from, after an interval of) max 3 occ.
            # P P66: 為 wèi (for) max 9 occ.
            'P02'   => ['pos' => 'adp', 'adpostype' => 'prep', 'other' => {'subpos' => 'P02'}],
            # conjunction
            # C Caa: 、, 和 = and, 及 = and, 與 = versus, 或 = or
            # C Caa[P1]: 從 = from, 又 = again, 既 = already, 由 = from, 或 = or
            # C Caa[P2]: 又 = again, 到 = to, 至 = to, 或 = or, 也 = also
            # C Cab: 等 = etc., 等等 = and so on, 之類 = the class, 什麼的 = something, 、
            # C Cbaa: 因為 = because, 如果 = in case, 因 = because, 雖然 = though, 若 = if
            # C Cbab: 的話 = if, 應該 = should, 而 = while, 能 = can/able, 並 = and
            # C Cbba: 由於 = due to, 雖 = although, 連 = even though, 既然 = since, 就是 = that
            # C Cbbb: 不但 = not only, 不僅 = not only, 一方面 = on the one hand, 首先 = first of all, 二 = two
            # C Cbca: 而 = and, 但 = but, 因此 = as such, 所以 = and so, 但是 = but
            # C Cbcb: 並 = and, 而且 = and, 且 = and, 並且 = and, 反而 = instead
            'Caa'  => ['pos' => 'conj', 'conjtype' => 'coor'],
            'Cab'  => ['pos' => 'conj', 'conjtype' => 'coor', 'other' => {'subpos' => 'ab'}],
            'Cbaa' => ['pos' => 'conj', 'conjtype' => 'sub'],
            'Cbab' => ['pos' => 'conj', 'conjtype' => 'sub', 'other' => {'subpos' => 'bab'}],
            'Cbba' => ['pos' => 'conj', 'conjtype' => 'sub', 'other' => {'subpos' => 'bba'}],
            'Cbbb' => ['pos' => 'conj', 'conjtype' => 'sub', 'other' => {'subpos' => 'bbb'}],
            'Cbca' => ['pos' => 'conj', 'conjtype' => 'coor', 'other' => {'subpos' => 'bca'}],
            'Cbcb' => ['pos' => 'conj', 'conjtype' => 'coor', 'other' => {'subpos' => 'bcb'}],
            # the "de" particle (two kinds)
            # DE DE: 的 de = of, 之 zhī = of, 得 dé = get, 地 de = ground/land/earth (tagging error?)
            # DE Di: 了 le, 著 zhe, 過 guò, 起來 qǐlái, 起 qǐ
            'DE'   => ['pos' => 'part', 'case' => 'gen'],
            'Di'   => ['pos' => 'part', 'case' => 'gen', 'other' => {'subpos' => 'Di'}],
            # particle
            'T'    => ['pos' => 'part'],
            # interjection
            'I'    => ['pos' => 'int']
        },
        'encode_map' =>
        {
            'pos' => { 'noun' => { 'nountype' => { 'com'   => { 'other/subpos' => { 'ab'  => 'Nab',
                                                                                    'ac'  => 'Nac',
                                                                                    'ad'  => 'Nad',
                                                                                    'aea' => 'Naea',
                                                                                    'aeb' => 'Naeb',
                                                                                    '@'   => 'Naa' }},
                                                   'prop'  => { 'other/subpos' => { 'bc'  => 'Nbc',
                                                                                    '@'   => 'Nba' }},
                                                   'class' => { 'other/subpos' => { 'fc'  => 'Nfc',
                                                                                    'fd'  => 'Nfd',
                                                                                    'fe'  => 'Nfe',
                                                                                    'fg'  => 'Nfg',
                                                                                    'fh'  => 'Nfh',
                                                                                    'fi'  => 'Nfi',
                                                                                    '@'   => 'Nfa' }},
                                                   '@'     => { 'advtype' => { 'loc' => { 'other/subpos' => { 'cb'  => 'Ncb',
                                                                                                              'cc'  => 'Ncc',
                                                                                                              'cda' => 'Ncda',
                                                                                                              'cdb' => 'Ncdb',
                                                                                                              'ce'  => 'Nce',
                                                                                                              '@'   => 'Nca' }},
                                                                               'tim' => { 'other/subpos' => { 'daab' => 'Ndaab',
                                                                                                              'daac' => 'Ndaac',
                                                                                                              'daad' => 'Ndaad',
                                                                                                              'daba' => 'Ndaba',
                                                                                                              'dabb' => 'Ndabb',
                                                                                                              'dabc' => 'Ndabc',
                                                                                                              'dabd' => 'Ndabd',
                                                                                                              'dabe' => 'Ndabe',
                                                                                                              'dabf' => 'Ndabf',
                                                                                                              'dbb'  => 'Ndbb',
                                                                                                              'dc'   => 'Ndc',
                                                                                                              'dda'  => 'Ndda',
                                                                                                              'ddb'  => 'Nddb',
                                                                                                              'ddc'  => 'Nddc',
                                                                                                              '@'    => 'Ndaaa' }},
                                                                               '@'   => { 'prontype' => { 'prs' => { 'reflex' => { 'reflex' => 'Nhab',
                                                                                                                                   '@'      => { 'politeness' => { 'pol' => 'Nhac',
                                                                                                                                                                   '@'   => 'Nhaa' }}}},
                                                                                                          'int' => 'Nhb',
                                                                                                          'prn' => 'Nhc',
                                                                                                          '@'   => { 'other/subpos' => { 'v2' => 'Nv2',
                                                                                                                                         'v3' => 'Nv3',
                                                                                                                                         'v4' => 'Nv4',
                                                                                                                                         '@'  => 'Nv1' }}}}}}}},
                       'adj'  => { 'prontype' => { 'dem' => 'Nep',
                                                   'prn' => { 'other/subpos' => { 'qb' => 'Neqb',
                                                                                  's'  => 'Nes',
                                                                                  '@'  => 'Neqa' }},
                                                   '@'   => { 'nountype' => { 'class' => 'DM',
                                                                              '@'     => 'A' }}}},
                       'num'  => 'Neu',
                       'verb' => 'V',
                       'adv'  => { 'prontype' => { 'int' => 'Dj',
                                                   '@'   => { 'negativeness' => { 'neg' => 'Dc',
                                                                                  '@'   => { 'other/subpos' => { 'ab'  => 'Dab',
                                                                                                                 'baa' => 'Dbaa',
                                                                                                                 'bab' => 'Dbab',
                                                                                                                 'bb'  => 'Dbb',
                                                                                                                 'bc'  => 'Dbc',
                                                                                                                 'd'   => 'Dd',
                                                                                                                 'fa'  => 'Dfa',
                                                                                                                 'fb'  => 'Dfb',
                                                                                                                 'g'   => 'Dg',
                                                                                                                 'h'   => 'Dh',
                                                                                                                 'k'   => 'Dk',
                                                                                                                 '@'   => 'Daa' }}}}}},
                       'adp'  => { 'adpostype' => { 'prep' => 'P',
                                                    'post' => 'Ng' }},
                       'conj' => { 'conjtype' => { 'coor' => { 'other/subpos' => { 'ab'  => 'Cab',
                                                                                   'bca' => 'Cbca',
                                                                                   'bcb' => 'Cbcb',
                                                                                   '@'   => 'Caa' }},
                                                   'sub'  => { 'other/subpos' => { 'bab' => 'Cbab',
                                                                                   'bba' => 'Cbba',
                                                                                   'bbb' => 'Cbbb',
                                                                                   '@'   => 'Cbaa' }}}},
                       'part' => { 'case' => { 'gen' => { 'other/subpos' => { 'Di' => 'Di',
                                                                              '@'  => 'DE' }},
                                               '@'   => 'T' }},
                       'int'  => 'I' }
        }
    );
    return \%atoms;
}



#------------------------------------------------------------------------------
# Creates the list of all surface CoNLL features that can appear in the FEATS
# column. This list will be used in decode().
#------------------------------------------------------------------------------
sub _create_features_all
{
    my $self = shift;
    my @features = ();
    return \@features;
}



#------------------------------------------------------------------------------
# Creates the list of surface CoNLL features that can appear in the FEATS
# column with particular parts of speech. This list will be used in encode().
#------------------------------------------------------------------------------
sub _create_features_pos
{
    my $self = shift;
    my %features =
    (
    );
    return \%features;
}



#------------------------------------------------------------------------------
# Decodes a physical tag (string) and returns the corresponding feature
# structure.
#------------------------------------------------------------------------------
sub decode
{
    my $self = shift;
    my $tag = shift;
    my $fs = Lingua::Interset::FeatureStructure->new();
    $fs->set_tagset('zh::conll');
    my $atoms = $self->atoms();
    # Three components: pos, subpos, features (always empty).
    # example: N\tNaa\t_
    my ($pos, $subpos, $features) = split(/\s+/, $tag);
    ###!!! We cannot currently decode the tag extensions in brackets, e.g. "[P1]" in "Caa[P1]".
    ###!!! In future we will want to create an atom to take care of them. For the moment, just a quick hack:
    $subpos =~ s/(\[.*?\])//;
    my $bracket = $1;
    if(defined($bracket))
    {
        $fs->set_other_subfeature('bracket', $bracket);
    }
    $atoms->{pos}->decode_and_merge_hard($subpos, $fs);
    return $fs;
}



#------------------------------------------------------------------------------
# Takes feature structure and returns the corresponding physical tag (string).
#------------------------------------------------------------------------------
sub encode
{
    my $self = shift;
    my $fs = shift; # Lingua::Interset::FeatureStructure
    my $atoms = $self->atoms();
    my $subpos = $atoms->{pos}->encode($fs);
    my $pos = $subpos =~ m/^(DE|Di)$/ ? 'DE' : $subpos eq 'DM' ? 'DM' : $subpos =~ m/^(N[eg])/ ? $1 : substr($subpos, 0, 1);
    ###!!! We cannot currently decode the tag extensions in brackets, e.g. "[P1]" in "Caa[P1]".
    ###!!! In future we will want to create an atom to take care of them. For the moment, just a quick hack:
    my $bracket = $fs->get_other_subfeature('zh::conll', 'bracket');
    if($bracket ne '')
    {
        $subpos .= $bracket;
    }
    my $tag = "$pos\t$subpos\t_";
    return $tag;
}



#------------------------------------------------------------------------------
# Returns reference to list of known tags.
# Tags were collected from the corpus, 294 distinct tags found.
# Cleaned up erroneous instances (e.g. with "[P2}" instead of "[P2]").
#------------------------------------------------------------------------------
sub list
{
    my $self = shift;
    my $list = <<end_of_list
A\tA\t_
C\tCaa\t_
C\tCaa[P1]\t_
C\tCaa[P2]\t_
C\tCab\t_
C\tCbaa\t_
C\tCbab\t_
C\tCbba\t_
C\tCbbb\t_
C\tCbca\t_
C\tCbcb\t_
D\tDaa\t_
D\tDab\t_
D\tDbaa\t_
D\tDbab\t_
D\tDbb\t_
D\tDbc\t_
D\tDc\t_
D\tDd\t_
D\tDfa\t_
D\tDfb\t_
D\tDg\t_
D\tDh\t_
D\tDj\t_
D\tDk\t_
DE\tDE\t_
DE\tDi\t_
DM\tDM\t_
I\tI\t_
Ne\tNep\t_
Ne\tNeqa\t_
Ne\tNeqb\t_
Ne\tNes\t_
Ne\tNeu\t_
Ng\tNg\t_
N\tNaa\t_
N\tNaa[+SPO]\t_
N\tNab\t_
N\tNab[+SPO]\t_
N\tNac\t_
N\tNac[+SPO]\t_
N\tNad\t_
N\tNad[+SPO]\t_
N\tNaea\t_
N\tNaeb\t_
N\tNba\t_
N\tNbc\t_
N\tNca\t_
N\tNcb\t_
N\tNcc\t_
N\tNcda\t_
N\tNcdb\t_
N\tNce\t_
N\tNdaaa\t_
N\tNdaab\t_
N\tNdaac\t_
N\tNdaad\t_
N\tNdaba\t_
N\tNdabb\t_
N\tNdabc\t_
N\tNdabd\t_
N\tNdabe\t_
N\tNdabf\t_
N\tNdbb\t_
N\tNdc\t_
N\tNdda\t_
N\tNddb\t_
N\tNddc\t_
N\tNfa\t_
N\tNfc\t_
N\tNfd\t_
N\tNfe\t_
N\tNfg\t_
N\tNfh\t_
N\tNfi\t_
N\tNhaa\t_
N\tNhab\t_
N\tNhac\t_
N\tNhb\t_
N\tNhc\t_
N\tNv1\t_
N\tNv2\t_
N\tNv3\t_
N\tNv4\t_
P\tP01\t_
P\tP02\t_
P\tP03\t_
P\tP04\t_
P\tP06\t_
P\tP06[P1]\t_
P\tP06[P2]\t_
P\tP06[+part]\t_
P\tP07\t_
P\tP08\t_
P\tP08[+part]\t_
P\tP09\t_
P\tP10\t_
P\tP11\t_
P\tP11[P1]\t_
P\tP11[P2]\t_
P\tP11[+part]\t_
P\tP12\t_
P\tP13\t_
P\tP14\t_
P\tP15\t_
P\tP16\t_
P\tP17\t_
P\tP18\t_
P\tP18[+part]\t_
P\tP19\t_
P\tP19[P1]\t_
P\tP19[P2]\t_
P\tP19[+part]\t_
P\tP20\t_
P\tP20[+part]\t_
P\tP21\t_
P\tP21[+part]\t_
P\tP22\t_
P\tP23\t_
P\tP24\t_
P\tP25\t_
P\tP26\t_
P\tP27\t_
P\tP28\t_
P\tP29\t_
P\tP30\t_
P\tP31\t_
P\tP31[P1]\t_
P\tP31[P2]\t_
P\tP31[+part]\t_
P\tP32\t_
P\tP32[+part]\t_
P\tP35\t_
P\tP35[+part]\t_
P\tP36\t_
P\tP37\t_
P\tP38\t_
P\tP39\t_
P\tP40\t_
P\tP41\t_
P\tP42\t_
P\tP42[+part]\t_
P\tP43\t_
P\tP44\t_
P\tP45\t_
P\tP46\t_
P\tP46[+part]\t_
P\tP47\t_
P\tP48\t_
P\tP48[+part]\t_
P\tP49\t_
P\tP50\t_
P\tP51\t_
P\tP52\t_
P\tP53\t_
P\tP54\t_
P\tP55\t_
P\tP55[+part]\t_
P\tP58\t_
P\tP59\t_
P\tP59[+part]\t_
P\tP60\t_
P\tP61\t_
P\tP62\t_
P\tP63\t_
P\tP64\t_
P\tP65\t_
P\tP66\t_
Str\tStr\t_
T\tTa\t_
T\tTb\t_
T\tTc\t_
T\tTd\t_
V\tV_11\t_
V\tV_12\t_
V\tV_2\t_
V\tVA\t_
V\tVA11\t_
V\tVA11[+ASP]\t_
V\tVA11[+NEG]\t_
V\tVA12\t_
V\tVA12[+NEG]\t_
V\tVA12[+SPV]\t_
V\tVA13\t_
V\tVA13[+ASP]\t_
V\tVA2\t_
V\tVA2[+ASP]\t_
V\tVA2[+SPV]\t_
V\tVA3\t_
V\tVA3[+ASP]\t_
V\tVA4\t_
V\tVA4[+ASP]\t_
V\tVA4[+NEG]\t_
V\tVA4[+NEG,+ASP]\t_
V\tVA4[+SPV]\t_
V\tVB11\t_
V\tVB11[+ASP]\t_
V\tVB11[+DE]\t_
V\tVB11[+NEG]\t_
V\tVB11[+SPV]\t_
V\tVB12\t_
V\tVB12[+ASP]\t_
V\tVB12[+NEG]\t_
V\tVB2\t_
V\tVB2[+ASP]\t_
V\tVB2[+NEG]\t_
V\tVC1\t_
V\tVC1[+NEG]\t_
V\tVC1[+SPV]\t_
V\tVC2\t_
V\tVC2[+ASP]\t_
V\tVC2[+DE]\t_
V\tVC2[+NEG]\t_
V\tVC2[+SPV]\t_
V\tVC31\t_
V\tVC31[+ASP]\t_
V\tVC31[+DE]\t_
V\tVC31[+DE,+ASP]\t_
V\tVC31[+NEG]\t_
V\tVC31[+SPV]\t_
V\tVC32\t_
V\tVC32[+DE]\t_
V\tVC32[+SPV]\t_
V\tVC33\t_
V\tVD1\t_
V\tVD2\t_
V\tVD2[+NEG]\t_
V\tVE11\t_
V\tVE12\t_
V\tVE2\t_
V\tVE2[+DE]\t_
V\tVE2[+NEG]\t_
V\tVE2[+SPV]\t_
V\tVF1\t_
V\tVF2\t_
V\tVG1\t_
V\tVG1[+NEG]\t_
V\tVG2\t_
V\tVG2[+DE]\t_
V\tVG2[+NEG]\t_
V\tVH11\t_
V\tVH11[+ASP]\t_
V\tVH11[+DE]\t_
V\tVH11[+NEG]\t_
V\tVH11[+SPV]\t_
V\tVH12\t_
V\tVH12[+ASP]\t_
V\tVH13\t_
V\tVH14\t_
V\tVH15\t_
V\tVH15[+NEG]\t_
V\tVH16\t_
V\tVH16[+ASP]\t_
V\tVH16[+NEG]\t_
V\tVH16[+SPV]\t_
V\tVH17\t_
V\tVH21\t_
V\tVH21[+ASP]\t_
V\tVH21[+Dbab]\t_
V\tVH21[+DE]\t_
V\tVH21[+NEG]\t_
V\tVH22\t_
V\tVI1\t_
V\tVI2\t_
V\tVI2[+ASP]\t_
V\tVI3\t_
V\tVJ1\t_
V\tVJ1[+DE]\t_
V\tVJ1[+NEG]\t_
V\tVJ2\t_
V\tVJ2[+NEG]\t_
V\tVJ2[+SPV]\t_
V\tVJ3\t_
V\tVJ3[+DE]\t_
V\tVJ3[+NEG]\t_
V\tVK1\t_
V\tVK1[+ASP]\t_
V\tVK1[+DE]\t_
V\tVK1[+NEG]\t_
V\tVK2\t_
V\tVK2[+NEG]\t_
V\tVL1\t_
V\tVL2\t_
V\tVL3\t_
V\tVL4\t_
V\tVP\t_
end_of_list
    ;
    # Protect from editors that replace tabs by spaces.
    $list =~ s/ \s+/\t/sg;
    my @list = split(/\r?\n/, $list);
    return \@list;
}



1;

=head1 SYNOPSIS

  use Lingua::Interset::Tagset::ZH::Conll;
  my $driver = Lingua::Interset::Tagset::ZH::Conll->new();
  my $fs = $driver->decode("N\tNaa\t_");

or

  use Lingua::Interset qw(decode);
  my $fs = decode('zh::conll', "N\tNaa\t_");

=head1 DESCRIPTION

Interset driver for the Chinese tagset of the CoNLL 2006 and 2007 Shared Tasks.
CoNLL tagsets in Interset are traditionally three values separated by tabs.
The values come from the CoNLL columns CPOS, POS and FEAT. For Chinese,
these values are derived from the tagset of the Academia Sinica Treebank
and the FEAT column is always empty.

=head1 SEE ALSO

L<Lingua::Interset>,
L<Lingua::Interset::Tagset>,
L<Lingua::Interset::Tagset::Conll>,
L<Lingua::Interset::FeatureStructure>

=cut
