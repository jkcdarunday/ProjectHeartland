// Iron crates
extern crate iron;
extern crate mount;
extern crate persistent;

#[macro_use]
extern crate router;

// Database crates
extern crate r2d2;
extern crate r2d2_redis;
extern crate redis;
// extern crate r2d2_mysql
// extern crate mysql_simple

// Iron dependencies
use mount::Mount;

use persistent::Read;

use iron::Iron;
use iron::Chain;

// Handler module
mod handler;
mod database;

// Shared pools
use database::RedisPool;

fn main(){
    let student_router = router!(
        get "/schedule" => handler::Enlisted::get,
        put "/schedule" => handler::Enlisted::put,
        delete "/schedule" => handler::Enlisted::del,

        get "/waitlist" => handler::Waitlist::get,
        put "/waitlist" => handler::Waitlist::put,
        delete "/waitlist" => handler::Waitlist::del
    );

    let auth_router = router!(
        post "/login" => handler::Auth::post,
        delete "/logout/:sid" => handler::Auth::del,
    );

    let subject_router = router!(
        get "/:subject" => handler::Subject::get
    );

    println!("Connecting to database..");
    let redis_db = database::redis_connect("redis://127.0.0.1", 512);
    println!("Done.");

    let mut mount = Mount::new();
    mount.mount("/student/", student_router);
    mount.mount("/auth/", auth_router);
    mount.mount("/subjects/", subject_router);

    let mut chain = Chain::new(mount);
    chain.link(Read::<RedisPool>::both(redis_db));

    Iron::new(chain).listen_with("0.0.0.0:3000", 512, iron::Protocol::Http, None).unwrap();
    println!("Started listening.");
}
