#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use rocket_contrib::json::Json;

use gethostname::gethostname;


#[get("/")]
fn index() -> Json<String> {
    let hostname = gethostname().into_string().unwrap();
    // Json("hostname": hostname)
    Json(hostname)
}

fn main() {
    rocket::ignite().mount("/", routes![index]).launch();
}
