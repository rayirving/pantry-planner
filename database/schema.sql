CREATE TABLE users (
	user_id 		INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	username 		TEXT NOT NULL,
	email 			TEXT NOT NULL,
	password 		TEXT,
	pref_unit_system 	TEXT NOT NULL DEFAULT 'metric',
	created_at		TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	updated_at		TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT ck_unit_system_val
		CHECK (pref_unit_system IN ('metric', 'imperial'))
);

CREATE UNIQUE INDEX index_users_username
	ON users (LOWER(username));

CREATE UNIQUE INDEX index_users_email
	ON users (LOWER(email));


CREATE TABLE ingredients (
	ingredient_id 	INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	user_id	       	INT,
	name		TEXT NOT NULL,
	mass_val	NUMERIC,
	volume_val	NUMERIC,
	count_val	NUMERIC,
	count_unit	TEXT,
	created_at	TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	updated_at	TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
	

	CONSTRAINT fk_users_ingredients 
		FOREIGN KEY (user_id) 
		REFERENCES users(user_id) ON DELETE CASCADE,
	CONSTRAINT ck_at_least_one_val_not_null
		CHECK (COALESCE(mass_val, volume_val, count_val) IS NOT NULL),
	CONSTRAINT ck_unit_val_not_null
		CHECK (count_unit IS NULL or count_val IS NOT NULL),
	CONSTRAINT ck_mass_pos
		CHECK (mass_val > 0 OR mass_val IS NULL),
	CONSTRAINT ck_volume_pos
		CHECK (volume_val > 0 OR volume_val IS NULL),
	CONSTRAINT ck_count_pos
		CHECK (count_val > 0 OR count_val IS NULL)
);

CREATE UNIQUE INDEX index_ingredients_user_name
	ON ingredients (user_id, LOWER(name)) NULLS NOT DISTINCT;