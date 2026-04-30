-- ════════════════════════════════════════════════════════════════════════════
-- ZussGo — destinations table + 50+ India seed
-- Migration: 20260430000000_destinations_seed.sql
-- ════════════════════════════════════════════════════════════════════════════

create table if not exists public.destinations (
  id             uuid primary key default gen_random_uuid(),
  name           text not null,
  region         text not null,
  state          text default '',
  image_url      text default '',
  categories     text[] default '{}',
  top_vibe       text default '',
  description    text default '',
  highlights     text[] default '{}',
  best_time      text default '',
  mood_tags      text[] default '{}',
  cost_hint      text default '',
  badge          text default '',
  map_x          float default 0.5,
  map_y          float default 0.5,
  node_color     text default '#1EC9B8',
  is_origin_city boolean default false,
  created_at     timestamptz default now()
);

alter table public.destinations enable row level security;

drop policy if exists "destinations_public_read" on public.destinations;
create policy "destinations_public_read"
  on public.destinations for select using (true);

-- ── Seed: skip if already populated ─────────────────────────────────────────
do $$ begin
  if (select count(*) from public.destinations) > 0 then
    raise notice 'destinations already seeded, skipping.';
    return;
  end if;

  -- ── BEACHES ────────────────────────────────────────────────────────────────
  insert into public.destinations
    (name, region, state, image_url, categories, top_vibe, description, highlights, best_time, mood_tags, cost_hint, badge, map_x, map_y, node_color, is_origin_city)
  values

  ('Goa', 'Goa, India', 'Goa',
   'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','party','budget','nightlife'], '🌊 Beach & Party',
   'India''s premier beach destination with sun-soaked shores, vibrant nightlife, Portuguese-era churches, and a laid-back vibe that draws millions every year.',
   ARRAY['Baga & Anjuna Beach','Dudhsagar Falls','Old Goa Basilica','Saturday Night Market','Spice Plantations'],
   'Nov – Feb', ARRAY['🌊 Beach','🍹 Nightlife','🏛 Heritage','🎵 Music'], '₹2,000–4,500/day', 'Most Popular',
   0.27, 0.60, '#1EC9B8', false),

  ('Andaman & Nicobar', 'Andaman Islands', 'Andaman',
   'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','adventure','diving'], '🏝 Island Life',
   'Crystal-clear turquoise waters, world-class snorkeling reefs, pristine white-sand beaches, and dense rainforests virtually untouched by mass tourism.',
   ARRAY['Radhanagar Beach','Neil Island','Cellular Jail','Elephant Beach','Scuba at Havelock'],
   'Oct – May', ARRAY['🤿 Diving','🏝 Beaches','🌴 Tropical','🚣 Kayaking'], '₹3,500–7,000/day', 'Hidden Paradise',
   0.75, 0.68, '#1EC9B8', false),

  ('Lakshadweep', 'Lakshadweep Islands', 'Lakshadweep',
   'https://images.unsplash.com/photo-1573843981267-be1999ff37cd?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','adventure','diving'], '🪸 Coral Atoll',
   'India''s smallest union territory — 36 coral islands with some of the clearest lagoons in the world and vibrant marine biodiversity.',
   ARRAY['Agatti Island','Bangaram Atoll','Lagoon Snorkeling','Deep Sea Fishing'],
   'Oct – May', ARRAY['🪸 Coral','🤿 Diving','🏝 Secluded','🐠 Marine Life'], '₹8,000–15,000/day', 'Permit Required',
   0.22, 0.72, '#58DAD0', false),

  ('Varkala', 'Kerala, India', 'Kerala',
   'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','yoga','budget','spiritual'], '🧘 Cliff Beach',
   'A dramatic cliff-backed beach town famous for mineral springs, yoga retreats, Ayurvedic centers, and a laid-back bohemian culture.',
   ARRAY['Varkala Cliff','Papanasam Beach','Janardanaswamy Temple','Ayurvedic Spa'],
   'Nov – Mar', ARRAY['🧘 Yoga','🌅 Sunset','🌊 Beach','🌿 Wellness'], '₹1,500–3,000/day', 'Yoga Hub',
   0.33, 0.82, '#58DAD0', false),

  ('Palolem Beach', 'South Goa, India', 'Goa',
   'https://images.unsplash.com/photo-1601944177325-f8867652837f?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','budget','party'], '🌴 South Goa Cove',
   'South Goa''s most beautiful crescent beach — calmer than the north, with dolphin cruises, silent discos, and palm-lined shacks serving fresh seafood.',
   ARRAY['Dolphin Spotting Cruise','Silent Disco','Kayaking','Butterfly Beach Hike','Beach Shacks'],
   'Nov – Mar', ARRAY['🌴 Beach','🐬 Dolphins','🤫 Silent Disco','🦞 Seafood'], '₹1,500–3,500/day', 'Best Goa Beach',
   0.28, 0.62, '#1EC9B8', false),

  -- ── MOUNTAINS ──────────────────────────────────────────────────────────────
  ('Leh Ladakh', 'Ladakh, India', 'Ladakh',
   'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','adventure','roadtrip'], '🏔 High Altitude Expedition',
   'The land of high passes and azure lakes at 3,500m+. Pangong Lake, ancient monasteries, stark lunar landscapes, and the world''s highest motorable roads.',
   ARRAY['Pangong Tso Lake','Nubra Valley','Khardung La Pass','Hemis Monastery','Magnetic Hill','Zanskar Valley'],
   'Jun – Sep', ARRAY['🏔 Mountains','🛣 Road Trip','🧘 Spiritual','⭐ Stargazing'], '₹3,000–6,000/day', 'Bucket List',
   0.38, 0.07, '#B57BFF', false),

  ('Spiti Valley', 'Himachal Pradesh', 'Himachal Pradesh',
   'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','adventure','offbeat'], '🏔 Cold Desert',
   'An untouched cold desert valley — ancient monasteries, bone-dry landscapes, dramatic gorges, and starry skies unlike anywhere in India.',
   ARRAY['Key Monastery','Chandratal Lake','Pin Valley','Dhankar Monastery','Kibber Village'],
   'Jun – Oct', ARRAY['🏔 High Altitude','🌌 Stargazing','🧘 Peace','📸 Photography'], '₹2,500–5,000/day', 'Offbeat Gem',
   0.44, 0.10, '#F7B84E', false),

  ('Manali', 'Himachal Pradesh', 'Himachal Pradesh',
   'https://images.unsplash.com/photo-1623143521360-1e5ce6c9657b?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','adventure','budget','roadtrip'], '🏔 Trek & Chill',
   'Gateway to the high Himalayan passes — Rohtang, Solang Valley snow sports, Beas River rafting, Old Manali''s café scene, and lush Kullu Valley.',
   ARRAY['Rohtang Pass','Solang Valley','Hadimba Temple','Old Manali Cafes','Beas River Rafting'],
   'Oct–Dec (snow), Mar–Jun (summer)', ARRAY['🏔 Snow','🛻 Adventure','☕ Cafes','🎿 Skiing'], '₹1,800–4,000/day', 'Year-Round',
   0.40, 0.13, '#B57BFF', false),

  ('Dharamshala & McLeod Ganj', 'Himachal Pradesh', 'Himachal Pradesh',
   'https://images.unsplash.com/photo-1586611292717-f828b167408c?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','spiritual','budget','culture'], '🙏 Little Tibet',
   'Home of the Dalai Lama and the Tibetan government-in-exile. Tibetan culture, Buddhist monasteries, trekking to Triund, and excellent momos.',
   ARRAY['Triund Trek','Namgyal Monastery','Tibetan Museum','Bhagsu Waterfall','Dal Lake McLeod'],
   'Mar – Jun, Sep – Nov', ARRAY['🧘 Spiritual','🏔 Trekking','🍜 Tibetan Food','🛕 Buddhist'], '₹1,200–2,500/day', 'Cultural Hub',
   0.42, 0.15, '#F7B84E', false),

  ('Auli', 'Uttarakhand', 'Uttarakhand',
   'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','adventure','skiing'], '🎿 Ski Paradise',
   'India''s premier skiing destination with Himalayan panoramas, cable car rides offering views of Nanda Devi, and meadows blanketed in snow.',
   ARRAY['Auli Ski Resort','Gorson Bugyal Meadow','Joshimath','Nanda Devi View','Cable Car Ride'],
   'Jan – Mar (ski), May – Nov (trek)', ARRAY['🎿 Skiing','🏔 Mountains','📸 Photography','🌿 Trekking'], '₹2,500–5,500/day', 'Ski Hub',
   0.47, 0.18, '#B57BFF', false),

  ('Kasol & Kheerganga', 'Himachal Pradesh', 'Himachal Pradesh',
   'https://images.unsplash.com/photo-1572037064580-75aba34b9c1e?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','budget','adventure','backpacker'], '🏕 Backpacker Heaven',
   'The Parvati Valley''s bohemian heart — Israeli restaurants, Kheerganga hot springs trek, and raw Himalayan beauty on a shoestring.',
   ARRAY['Kheerganga Hot Springs','Chalal Village','Tosh Village','Manikaran Gurudwara','Parvati River'],
   'Mar – Jun, Sep – Nov', ARRAY['🏕 Camping','♨️ Hot Springs','🎒 Backpacking','🌿 Nature'], '₹800–2,000/day', 'Budget Favorite',
   0.41, 0.12, '#1EC9B8', false),

  ('Rishikesh', 'Uttarakhand', 'Uttarakhand',
   'https://images.unsplash.com/photo-1591018653342-6ecde00af4c7?auto=format&fit=crop&w=800&q=80',
   ARRAY['spiritual','adventure','yoga','budget'], '🌊 Yoga Capital',
   'The yoga and adventure capital of India — rafting on the Ganga, bungee jumping, a hundred ashrams, Laxman Jhula, and stunning evening Ganga Aarti.',
   ARRAY['Rafting on Ganga','Laxman Jhula','Triveni Ghat Aarti','Bungee Jumping','Yoga Ashrams'],
   'Sep – Jun', ARRAY['🧘 Yoga','🌊 Rafting','🙏 Spiritual','🏕 Camp'], '₹1,000–3,000/day', 'Adventure + Spirit',
   0.48, 0.20, '#1EC9B8', false),

  ('Nainital', 'Uttarakhand', 'Uttarakhand',
   'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','budget','nature'], '⛵ Lake Hill Station',
   'A picturesque Kumaon hill town built around the glacial Naini Lake — boating, cable car rides to Snow View, and the colonial-era Mall Road.',
   ARRAY['Naini Lake Boating','Snow View Cable Car','Naina Devi Temple','Mall Road','Tiffin Top Hike'],
   'Mar – Jun, Sep – Nov', ARRAY['⛵ Boating','🏔 Hills','🌿 Nature','☕ Cafes'], '₹1,500–3,500/day', 'Classic Hill Station',
   0.49, 0.19, '#58DAD0', false),

  -- ── HERITAGE & CULTURE ────────────────────────────────────────────────────
  ('Rajasthan – Jaipur', 'Rajasthan, India', 'Rajasthan',
   'https://images.unsplash.com/photo-1477587458883-47145ed31282?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture','foodie'], '🏛 Pink City',
   'The Pink City — Amber Fort, Hawa Mahal, Jantar Mantar, royal palaces, vibrant bazaars, and Rajasthani cuisine at every corner.',
   ARRAY['Amber Fort','Hawa Mahal','City Palace','Jantar Mantar','Johari Bazaar','Nahargarh Fort'],
   'Oct – Mar', ARRAY['🏛 Heritage','👑 Royal','🛍 Shopping','🍛 Food'], '₹2,000–5,000/day', 'UNESCO City',
   0.30, 0.30, '#F7B84E', false),

  ('Rajasthan – Jaisalmer', 'Rajasthan, India', 'Rajasthan',
   'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','adventure','desert'], '🏜 Golden City',
   'A golden sandstone fort rising from the Thar Desert — camel safaris, dune camping under the stars, havelis with intricate carvings, and sunset views.',
   ARRAY['Jaisalmer Fort','Sam Sand Dunes','Camel Safari','Gadisar Lake','Patwon ki Haveli'],
   'Oct – Mar', ARRAY['🏜 Desert','🐪 Camel Safari','🌅 Sunset','⭐ Stargazing'], '₹2,500–5,000/day', 'Desert Magic',
   0.22, 0.32, '#F7B84E', false),

  ('Rajasthan – Udaipur', 'Rajasthan, India', 'Rajasthan',
   'https://images.unsplash.com/photo-1568322445389-f64ac2515020?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','romance','culture'], '💎 City of Lakes',
   'Rajasthan''s most romantic city — the Lake Palace floating on Pichola, City Palace complex, Jag Mandir, and mesmerizing sunsets over the Aravalli Hills.',
   ARRAY['Lake Pichola Boat','City Palace','Jag Mandir','Sajjangarh Monsoon Palace','Bagore ki Haveli'],
   'Oct – Mar', ARRAY['💕 Romantic','🏛 Heritage','🚣 Lakes','🎨 Art'], '₹2,500–6,000/day', 'Most Romantic',
   0.28, 0.38, '#F7B84E', false),

  ('Rajasthan – Jodhpur', 'Rajasthan, India', 'Rajasthan',
   'https://images.unsplash.com/photo-1590377503374-cbfc86e40f87?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture','adventure'], '💙 Blue City',
   'The Blue City where indigo-washed houses cascade beneath the mighty Mehrangarh Fort — one of India''s largest and most dramatic hilltop fortresses.',
   ARRAY['Mehrangarh Fort','Jaswant Thada','Clock Tower Market','Umaid Bhawan Palace','Flying Fox Zipline'],
   'Oct – Mar', ARRAY['🏛 Fort','🛍 Bazaar','🪂 Adventure','📸 Photography'], '₹1,800–4,500/day', 'Blue City',
   0.25, 0.34, '#58DAD0', false),

  ('Varanasi', 'Uttar Pradesh', 'Uttar Pradesh',
   'https://images.unsplash.com/photo-1561361058-c24cecae35ca?auto=format&fit=crop&w=800&q=80',
   ARRAY['spiritual','heritage','culture'], '🕌 Eternal City',
   'The world''s oldest living city — ghats stretching 5km along the Ganga, Ganga Aarti at Dashashwamedh, ancient temples, and the city''s raw, timeless spirituality.',
   ARRAY['Dashashwamedh Ghat Aarti','Kashi Vishwanath Temple','Boat Ride at Sunrise','Sarnath','Manikarnika Ghat'],
   'Oct – Mar', ARRAY['🙏 Spiritual','🕯 Aarti','⛵ Boat Rides','🛕 Temples'], '₹1,200–2,500/day', 'Spiritual Capital',
   0.55, 0.33, '#F7B84E', false),

  ('Agra', 'Uttar Pradesh', 'Uttar Pradesh',
   'https://images.unsplash.com/photo-1564507592333-c60657eea523?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture'], '🕌 Taj Mahal',
   'Home to the Taj Mahal — one of the Seven Wonders of the World. Also Agra Fort, Fatehpur Sikri, and the Mughal heritage of the Golden Triangle.',
   ARRAY['Taj Mahal Sunrise','Agra Fort','Fatehpur Sikri','Mehtab Bagh Sunset View','Itmad-ud-Daulah'],
   'Oct – Mar', ARRAY['🏛 Mughal','📸 Photography','👑 Royal','🌅 Sunrise'], '₹1,500–4,000/day', '7 Wonders',
   0.48, 0.27, '#F7B84E', false),

  ('Hampi', 'Karnataka, India', 'Karnataka',
   'https://images.unsplash.com/photo-1570170531776-8d4e5a1d38fb?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','adventure','budget','offbeat'], '🏛 Ruins & Boulders',
   'A UNESCO World Heritage landscape of surreal boulder fields and the magnificent ruins of the Vijayanagara Empire, with the Tungabhadra River flowing through.',
   ARRAY['Virupaksha Temple','Vittala Temple Stone Chariot','Matanga Hill Sunrise','Coracle Ride','Royal Enclosure'],
   'Oct – Feb', ARRAY['🏛 Ruins','🧗 Bouldering','🚲 Cycling','📸 Photography'], '₹800–2,000/day', 'UNESCO World Heritage',
   0.40, 0.67, '#B57BFF', false),

  ('Khajuraho', 'Madhya Pradesh', 'Madhya Pradesh',
   'https://images.unsplash.com/photo-1590169016523-07b2f4ad3d04?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture'], '🏛 Temple Town',
   'Medieval temple complexes with extraordinarily detailed sculptures — a UNESCO World Heritage Site and a testament to the artistry of ancient India.',
   ARRAY['Western Temple Group','Kandariya Mahadev Temple','Light & Sound Show','Panna Tiger Reserve'],
   'Oct – Mar', ARRAY['🏛 Temples','📸 Art','🌿 Nature','🎭 Culture'], '₹1,500–3,000/day', 'UNESCO Site',
   0.52, 0.37, '#F7B84E', false),

  ('Pondicherry', 'Pondicherry, India', 'Pondicherry',
   'https://images.unsplash.com/photo-1589308078059-be1415eab4c3?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','heritage','yoga','spiritual'], '🇫🇷 French Riviera of India',
   'French colonial streets, Auroville''s utopian community, pastel-colored buildings by the Bay of Bengal, and superb French-Tamil fusion cuisine.',
   ARRAY['French Quarter Walk','Auroville Matrimandir','Paradise Beach','Sri Aurobindo Ashram','Promenade Beach'],
   'Oct – Mar', ARRAY['🏛 French Colonial','🧘 Spiritual','🌊 Beach','☕ Café Culture'], '₹1,800–4,500/day', 'French Quarter',
   0.47, 0.73, '#58DAD0', false),

  -- ── WILDLIFE & NATURE ────────────────────────────────────────────────────
  ('Ranthambore', 'Rajasthan, India', 'Rajasthan',
   'https://images.unsplash.com/photo-1593179357196-ea11a2e7c119?auto=format&fit=crop&w=800&q=80',
   ARRAY['wildlife','adventure'], '🐯 Tiger Territory',
   'One of India''s best places to spot wild Bengal tigers — the ruins of Ranthambore Fort overlook the lakes where tigers come to drink at dusk.',
   ARRAY['Tiger Safari','Ranthambore Fort','Padam Lake','Jogi Mahal','Bird Watching'],
   'Oct – Jun', ARRAY['🐯 Tiger Safari','🌿 Wildlife','📸 Photography','🏛 Ruins'], '₹3,000–7,000/day', 'Tiger Reserve',
   0.35, 0.33, '#F7B84E', false),

  ('Jim Corbett', 'Uttarakhand', 'Uttarakhand',
   'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=800&q=80',
   ARRAY['wildlife','adventure'], '🐘 India''s First National Park',
   'India''s oldest national park — home to tigers, elephants, leopards, and over 600 bird species in the Himalayan foothills.',
   ARRAY['Dhikala Zone Safari','Bijrani Zone','Corbett Waterfall','Garjia Devi Temple','River Ramganga'],
   'Nov – Jun', ARRAY['🐯 Tiger','🐘 Elephant','🦅 Birding','🏕 Nature'], '₹3,500–8,000/day', 'National Park',
   0.50, 0.20, '#58DAD0', false),

  ('Kaziranga', 'Assam, India', 'Assam',
   'https://images.unsplash.com/photo-1580894908361-967195033215?auto=format&fit=crop&w=800&q=80',
   ARRAY['wildlife','adventure'], '🦏 Rhino Capital',
   'UNESCO World Heritage Site home to 2/3 of the world''s one-horned rhinos, along with tigers, elephants, and vast Brahmaputra floodplains.',
   ARRAY['Jeep Safari','Elephant Safari','Central Range','Western Kohora Zone','Birdwatching'],
   'Nov – Apr', ARRAY['🦏 Rhino','🐯 Tiger','🐘 Elephant','🌿 Wetlands'], '₹3,000–6,000/day', 'UNESCO Site',
   0.83, 0.22, '#1EC9B8', false),

  ('Sundarbans', 'West Bengal', 'West Bengal',
   'https://images.unsplash.com/photo-1617043786394-f977fa12eddf?auto=format&fit=crop&w=800&q=80',
   ARRAY['wildlife','adventure','offbeat'], '🐅 Mangrove Delta',
   'The world''s largest mangrove forest and home to the Royal Bengal Tiger — boat safaris through tidal waterways at the Ganges-Brahmaputra delta.',
   ARRAY['Boat Safari','Sajnekhali Watch Tower','Tiger Spotting','Sudhanyakhali Camp','Village Walk'],
   'Sep – Mar', ARRAY['🐅 Tiger','🚣 Boat Safari','🌿 Mangrove','🦅 Birds'], '₹2,500–5,500/day', 'UNESCO Biosphere',
   0.70, 0.42, '#1EC9B8', false),

  -- ── KERALA ────────────────────────────────────────────────────────────────
  ('Kerala Backwaters – Alleppey', 'Kerala, India', 'Kerala',
   'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?auto=format&fit=crop&w=800&q=80',
   ARRAY['beaches','heritage','budget','wellness'], '🌿 Backwaters',
   'Float through 900km of emerald backwater canals on a houseboat, surrounded by coconut palms, rice paddies, and the serene rhythms of village life.',
   ARRAY['Houseboat Stay','Alleppey Canals','Marari Beach','Kumarakom Bird Sanctuary','Village Backwater Tour'],
   'Sep – Mar', ARRAY['🚣 Houseboat','🌿 Nature','🏡 Village','🌅 Sunset'], '₹2,000–6,000/day', 'Houseboat Capital',
   0.35, 0.80, '#58DAD0', false),

  ('Munnar', 'Kerala, India', 'Kerala',
   'https://images.unsplash.com/photo-1588416936097-41850ab3d86d?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','wellness','budget'], '🍃 Tea Country',
   'Endless rolling hills covered in emerald tea gardens at 1,600m — misty valleys, Attukal waterfalls, Eravikulam tahr, and cool mountain air.',
   ARRAY['Tea Gardens','Eravikulam National Park','Attukal Waterfalls','Top Station','Mattupetty Dam'],
   'Sep – May', ARRAY['🍵 Tea','🌿 Nature','🏔 Hills','🦌 Wildlife'], '₹1,500–4,000/day', 'Hill Station',
   0.36, 0.78, '#58DAD0', false),

  -- ── NORTHEAST ────────────────────────────────────────────────────────────
  ('Meghalaya – Shillong & Cherrapunjee', 'Meghalaya, India', 'Meghalaya',
   'https://images.unsplash.com/photo-1596895111956-bf1cf0599ce5?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','adventure','offbeat','nature'], '☁️ Scotland of the East',
   'The wettest place on Earth — living root bridges, Nohkalikai Falls, Dawki''s transparent river, and the rolling Khasi Hills draped in perpetual mist.',
   ARRAY['Living Root Bridge','Nohkalikai Falls','Dawki River','Ward''s Lake Shillong','Mawlynnong Cleanest Village'],
   'Oct – Jun', ARRAY['🌧 Monsoon','🌿 Nature','📸 Photography','🧗 Adventure'], '₹1,500–3,500/day', 'Offbeat Must-See',
   0.86, 0.28, '#1EC9B8', false),

  ('Sikkim – Gangtok & North Sikkim', 'Sikkim, India', 'Sikkim',
   'https://images.unsplash.com/photo-1544735716-392fe2489ffa?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','spiritual','offbeat','adventure'], '🏔 Himalayan Kingdom',
   'Dramatic Kanchenjunga views, Yumthang Valley of Flowers, Gurudongmar Lake at 5,148m, and Buddhist monasteries around every bend.',
   ARRAY['Yumthang Valley','Gurudongmar Lake','Rumtek Monastery','MG Marg Gangtok','Tsomgo Lake','Zero Point'],
   'Mar – Jun, Oct – Dec', ARRAY['🏔 Himalaya','🧘 Buddhist','🌸 Flowers','📸 Photography'], '₹2,500–5,500/day', 'Permit Zone',
   0.80, 0.24, '#B57BFF', false),

  ('Arunachal Pradesh – Tawang', 'Arunachal Pradesh', 'Arunachal Pradesh',
   'https://images.unsplash.com/photo-1624896085560-dcf46f55e64f?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','spiritual','offbeat','adventure'], '🛕 Frontier Monastery',
   'Asia''s second-largest monastery at 3,048m, Sela Pass at 4,170m, frozen lakes, pristine forests, and tribal culture at the India-China border.',
   ARRAY['Tawang Monastery','Sela Pass','Madhuri Lake','Bum La Border','Nuranang Falls'],
   'Mar – Oct', ARRAY['🛕 Buddhist','🏔 High Altitude','🌨 Snow','🌺 Tribal Culture'], '₹2,500–5,000/day', 'Inner Line Permit',
   0.90, 0.18, '#B57BFF', false),

  ('Dzukou Valley', 'Nagaland / Manipur', 'Nagaland',
   'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','adventure','offbeat','nature'], '🌸 Valley of Flowers Northeast',
   'A hidden paradise on the Nagaland-Manipur border — seasonal flowers blanketing the valley floor, camping under the stars, and no crowds whatsoever.',
   ARRAY['Dzukou Valley Trek','Bamboo Forest','Wildflower Meadows','Camping','Japfu Peak'],
   'Jun – Sep (flowers), Dec – Jan (snow)', ARRAY['🌸 Flowers','🏕 Camping','🌿 Trekking','📸 Untouched'], '₹1,500–3,000/day', 'Hidden Gem',
   0.88, 0.30, '#1EC9B8', false),

  -- ── CENTRAL & SOUTH ────────────────────────────────────────────────────
  ('Coorg', 'Karnataka, India', 'Karnataka',
   'https://images.unsplash.com/photo-1617793586756-31bc27a00c5a?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','wellness','nature','budget'], '☕ Coffee Country',
   'The Scotland of India — misty coffee and spice plantations, Abbey Falls, Raja''s Seat sunset point, and the warm Kodava hospitality.',
   ARRAY['Coffee Estate Tour','Abbey Falls','Dubare Elephant Camp','Raja''s Seat','Iruppu Falls'],
   'Oct – May', ARRAY['☕ Coffee','🌿 Plantation','🌧 Misty','🐘 Elephants'], '₹2,000–5,000/day', 'Coffee Capital',
   0.41, 0.71, '#1EC9B8', false),

  ('Mysore', 'Karnataka, India', 'Karnataka',
   'https://images.unsplash.com/photo-1600093112639-77d31b68bfe0?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture','foodie'], '🏰 Palace City',
   'The City of Palaces — the illuminated Mysore Palace is India''s most visited monument, flanked by Chamundi Hills, silk bazaars, and Dasara festival.',
   ARRAY['Mysore Palace (illuminated)','Chamundi Hills Temple','Devaraja Market','Brindavan Gardens','Srirangapatna'],
   'Oct – Mar', ARRAY['👑 Royal','🏛 Palace','🎆 Festival','🛍 Silk'], '₹1,500–3,500/day', 'Palace City',
   0.40, 0.72, '#F7B84E', false),

  ('Ooty', 'Tamil Nadu', 'Tamil Nadu',
   'https://images.unsplash.com/photo-1601637847413-94e13c5f5a67?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','budget','nature'], '🚂 Queen of Hills',
   'The Nilgiri Blue Mountain Railway (UNESCO), Ooty Lake, sprawling tea and rose gardens, homemade chocolate shops, and Doddabetta Peak at 2,637m.',
   ARRAY['Nilgiri Mountain Railway','Ooty Lake','Botanical Gardens','Doddabetta Peak','Tea Factory Tour'],
   'Mar – Jun, Sep – Nov', ARRAY['🚂 Train','🍵 Tea','🌸 Garden','🏔 Hills'], '₹1,200–3,000/day', 'Hill Station Classic',
   0.42, 0.79, '#58DAD0', false),

  ('Kodaikanal', 'Tamil Nadu', 'Tamil Nadu',
   'https://images.unsplash.com/photo-1622396481328-9b1b78cdd9fd?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','budget','nature','yoga'], '🌲 Princess of Hills',
   'A misty Palani Hills retreat — the star-shaped Kodaikanal Lake, Pillar Rocks, Bryant Park, Silver Cascade Falls, and excellent mountain cycling.',
   ARRAY['Kodaikanal Lake','Pillar Rocks','Bear Shola Falls','Bryant Park','Dolphin''s Nose Viewpoint'],
   'Apr – Jun, Sep – Nov', ARRAY['🌲 Forest','🌫 Misty','🚲 Cycling','🌸 Flowers'], '₹1,000–2,500/day', 'Hill Station',
   0.43, 0.80, '#1EC9B8', false),

  ('Mahabaleshwar', 'Maharashtra', 'Maharashtra',
   'https://images.unsplash.com/photo-1602787366440-13e09b0a7e45?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','budget','nature'], '🍓 Strawberry Hills',
   'Maharashtra''s highest hill station — sweeping Sahyadri valley views from Arthur''s Seat, strawberry farms, Venna Lake boating, and cool monsoon mists.',
   ARRAY['Arthur''s Seat Viewpoint','Venna Lake','Elephant''s Head Point','Strawberry Farms','Lingmala Waterfall'],
   'Oct – Jun', ARRAY['🏔 Hills','🍓 Strawberry','🌿 Nature','🌧 Monsoon'], '₹1,500–3,500/day', 'Weekend Escape',
   0.31, 0.55, '#58DAD0', false),

  ('Lonavala & Khandala', 'Maharashtra', 'Maharashtra',
   'https://images.unsplash.com/photo-1568876694728-451bbf694b83?auto=format&fit=crop&w=800&q=80',
   ARRAY['mountains','budget','adventure'], '🌧 Monsoon Escape',
   'The Sahyadri''s favorite monsoon getaway from Mumbai and Pune — Bhushi Dam overflow, Tiger''s Leap cliff, chikki shops, and Western Ghats trekking.',
   ARRAY['Bhushi Dam','Tiger''s Leap','Lohagad Fort Trek','Karla Caves','Rajmachi Trek'],
   'Jun – Sep (monsoon), Oct – Feb', ARRAY['🌧 Monsoon','🏔 Trekking','🏰 Forts','🍬 Food'], '₹1,200–3,000/day', 'Monsoon Getaway',
   0.30, 0.53, '#1EC9B8', false),

  ('Ajanta & Ellora Caves', 'Maharashtra', 'Maharashtra',
   'https://images.unsplash.com/photo-1585135497273-1a86b09fe70e?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture'], '🪨 Rock-Cut Wonders',
   'Two UNESCO World Heritage Sites — Ajanta''s 2nd century BC Buddhist cave paintings and Ellora''s multi-faith rock-cut temples spanning 600 years.',
   ARRAY['Ajanta Cave Paintings','Ellora Kailasa Temple','Daulatabad Fort','Bibi ka Maqbara'],
   'Nov – Mar', ARRAY['🏛 Ancient','🎨 Murals','🛕 Temples','📚 History'], '₹1,500–3,000/day', 'UNESCO Dual Site',
   0.36, 0.53, '#F7B84E', false),

  -- ── ODISHA & EAST ────────────────────────────────────────────────────────
  ('Puri & Konark', 'Odisha, India', 'Odisha',
   'https://images.unsplash.com/photo-1625484950978-24e38e1e2edb?auto=format&fit=crop&w=800&q=80',
   ARRAY['spiritual','beaches','heritage'], '☀️ Sun Temple & Sea',
   'The Konark Sun Temple (UNESCO) designed as a giant stone chariot, combined with Puri''s sacred Jagannath Temple and sweeping Bay of Bengal beaches.',
   ARRAY['Konark Sun Temple','Puri Beach','Jagannath Temple','Chilika Lake','Raghurajpur Artist Village'],
   'Oct – Feb', ARRAY['🛕 Temples','🌊 Beach','🎨 Art','🦅 Birds'], '₹1,200–2,500/day', 'UNESCO + Spiritual',
   0.65, 0.48, '#F7B84E', false),

  -- ── GUJARAT ──────────────────────────────────────────────────────────────
  ('Rann of Kutch', 'Gujarat, India', 'Gujarat',
   'https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?auto=format&fit=crop&w=800&q=80',
   ARRAY['adventure','culture','offbeat'], '🌕 White Desert',
   'The world''s largest salt flat — the Rann Utsav festival, flamingo flocks at Flamingo City, and the ancient Harappan site of Dholavira.',
   ARRAY['White Rann Sunset','Rann Utsav Festival','Flamingo City','Dholavira Ruins','Bhuj Handicrafts'],
   'Nov – Feb', ARRAY['🌕 Salt Desert','🦩 Flamingos','🎭 Festival','📸 Photography'], '₹2,000–4,500/day', 'Unique Landscape',
   0.22, 0.44, '#F7B84E', false),

  ('Gir National Park', 'Gujarat, India', 'Gujarat',
   'https://images.unsplash.com/photo-1551316679-9c6ae9dec224?auto=format&fit=crop&w=800&q=80',
   ARRAY['wildlife','adventure'], '🦁 Asiatic Lion',
   'The last refuge of the Asiatic lion on Earth — one of India''s greatest wildlife success stories, with over 600 lions now roaming the Gir forests.',
   ARRAY['Asiatic Lion Safari','Gir Jungle Trail','Kamleshwar Dam','Sasan Village','Bird Watching'],
   'Dec – Jun', ARRAY['🦁 Lions','🌿 Safari','📸 Wildlife','🌳 Forest'], '₹3,000–6,000/day', 'Only in India',
   0.20, 0.47, '#F7B84E', false),

  -- ── MADHYA PRADESH ──────────────────────────────────────────────────────
  ('Bhopal & Sanchi', 'Madhya Pradesh', 'Madhya Pradesh',
   'https://images.unsplash.com/photo-1574547296590-b7bbb4b84a1d?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','culture','spiritual'], '🕌 City of Lakes',
   'Bhopal''s twin lakes and nearby Sanchi''s Great Stupa — Emperor Ashoka''s 3rd century BC Buddhist monument, a UNESCO World Heritage Site.',
   ARRAY['Sanchi Great Stupa','Upper Lake Bhopal','Bharat Bhavan','Tribal Museum','Bhimbetka Rock Shelters'],
   'Oct – Mar', ARRAY['🏛 History','🛕 Buddhist','🎨 Tribal Art','🚣 Lakes'], '₹1,000–2,500/day', 'UNESCO Nearby',
   0.45, 0.43, '#B57BFF', false),

  ('Orchha', 'Madhya Pradesh', 'Madhya Pradesh',
   'https://images.unsplash.com/photo-1590377503374-cbfc86e40f87?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','offbeat','spiritual'], '🏯 Forgotten Kingdom',
   'A hidden gem of medieval palaces, cenotaphs, and temples on the Betwa River — largely untouched by mass tourism and jaw-dropping at every turn.',
   ARRAY['Jahangir Mahal','Chaturbhuj Temple','Raj Praveen Mahal','Betwa River Rafting','Cenotaphs Walk'],
   'Oct – Mar', ARRAY['🏯 Medieval','🌿 Quiet','🏛 Heritage','🚣 River'], '₹1,000–2,000/day', 'Hidden Heritage',
   0.48, 0.40, '#F7B84E', false),

  -- ── URBAN ────────────────────────────────────────────────────────────────
  ('Mumbai', 'Maharashtra', 'Maharashtra',
   'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?auto=format&fit=crop&w=800&q=80',
   ARRAY['urban','nightlife','foodie','heritage'], '🌆 Maximum City',
   'India''s financial capital — Marine Drive''s Queen''s Necklace, Dharavi, Bollywood, street food from vada pav to butter chicken rolls, and a never-sleeping nightlife.',
   ARRAY['Gateway of India','Marine Drive','Dharavi Walk','Colaba Causeway','Juhu Beach','Elephanta Caves'],
   'Nov – Feb', ARRAY['🌆 Urban','🎬 Bollywood','🍜 Street Food','🎭 Nightlife'], '₹2,500–8,000/day', 'Financial Capital',
   0.27, 0.49, '#1EC9B8', true),

  ('Delhi', 'Delhi, India', 'Delhi',
   'https://images.unsplash.com/photo-1587474260584-136574528ed5?auto=format&fit=crop&w=800&q=80',
   ARRAY['heritage','foodie','urban','culture'], '🏛 Capital City',
   'India''s historic capital — Mughal monuments, Chandni Chowk''s legendary street food, Lutyens'' Delhi''s grand avenues, and India''s most vibrant arts scene.',
   ARRAY['Red Fort','Qutub Minar','Chandni Chowk Food Tour','Humayun Tomb','Lodhi Art District','India Gate'],
   'Oct – Mar', ARRAY['🏛 History','🍛 Food','🎨 Art','🛍 Shopping'], '₹2,000–6,000/day', 'Heritage Capital',
   0.42, 0.23, '#58DAD0', true),

  -- ── ORIGIN CITIES (no detail page shown) ────────────────────────────────
  ('Bangalore', 'Karnataka', 'Karnataka', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.38, 0.69, '#1EC9B8', true),
  ('Kolkata', 'West Bengal', 'West Bengal', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.70, 0.36, '#B57BFF', true),
  ('Hyderabad', 'Telangana', 'Telangana', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.43, 0.60, '#F7B84E', true),
  ('Pune', 'Maharashtra', 'Maharashtra', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.31, 0.52, '#58DAD0', true),
  ('Chennai', 'Tamil Nadu', 'Tamil Nadu', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.46, 0.76, '#1EC9B8', true),
  ('Ahmedabad', 'Gujarat', 'Gujarat', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.26, 0.43, '#F7B84E', true),
  ('Jaipur', 'Rajasthan', 'Rajasthan', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.30, 0.30, '#F7B84E', true),
  ('Kochi', 'Kerala', 'Kerala', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.35, 0.79, '#1EC9B8', true),
  ('Surat', 'Gujarat', 'Gujarat', '', ARRAY[]::text[], '', '', ARRAY[]::text[], '', ARRAY[]::text[], '', '', 0.25, 0.46, '#F7B84E', true);

end $$;
