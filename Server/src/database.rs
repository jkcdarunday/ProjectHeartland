// Iron crates
extern crate iron;

// Database crates
extern crate r2d2;
extern crate r2d2_redis;
extern crate redis;

// Iron dependencies
use iron::typemap::Key;

// Database dependencies
use r2d2_redis::RedisConnectionManager;

// Persistent Pool
pub struct RedisPool;
impl Key for RedisPool { type Value = r2d2::Pool<RedisConnectionManager>; }

pub fn redis_connect(database: &str, pool_size: u32) -> r2d2::Pool<RedisConnectionManager>{
    let config = r2d2::Config::builder().pool_size(pool_size).build();
    let manager = RedisConnectionManager::new(database).unwrap();
    r2d2::Pool::new(config, manager).unwrap()
}
