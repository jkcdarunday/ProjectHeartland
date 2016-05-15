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

// Auth crates
extern crate uuid;
extern crate crypto;

// Iron dependencies
use mount::Mount;

use persistent::Read;

use iron::Iron;
use iron::Chain;

// Handler module
mod handler;

// Database module
mod database;

// Script module
mod scripts;

// Shared pools
use database::RedisPool;

// Shared scripts
use scripts::Scripts;

fn main(){
    let student_router = router!(
        get ":student_number/schedule" => handler::Enlisted::get,
        put ":student_number/schedule/:subject/:section" => handler::Enlisted::put,
        delete ":student_number/schedule/:subject/:section" => handler::Enlisted::del,

        get ":student_number/waitlist/:subject/:section" => handler::Waitlist::get,
        put ":student_number/waitlist/:subject/:section" => handler::Waitlist::put,
        delete ":student_number/waitlist/:subject/:section" => handler::Waitlist::del
    );

    let auth_router = router!(
        post "login/:username/:password" => handler::Auth::post,
        delete "logout/:sid" => handler::Auth::del,
        put "register/:student_number/:username/:password" => handler::Auth::put
    );

    let subject_router = router!(
        get "/:subject" => handler::Subject::get
    );

    println!("Connecting to database..");
    let redis_db = database::redis_connect("redis://127.0.0.1", 512);
    println!("Done.");

    println!("Loading scripts from ./lua/..");
    let shared_scripts = scripts::get_scripts();
    println!("Done.");

    let mut mount = Mount::new();
    mount.mount("/student/", student_router);
    mount.mount("/auth/", auth_router);
    mount.mount("/subjects/", subject_router);

    let mut chain = Chain::new(mount);
    chain.link(Read::<RedisPool>::both(redis_db));
    chain.link(Read::<Scripts>::both(shared_scripts));

    Iron::new(chain).listen_with("0.0.0.0:3000", 512, iron::Protocol::Http, None).unwrap();
    println!("Started listening.");
}
